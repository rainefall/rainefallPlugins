# Like fogs, but they don't repeat and can't move

class Spriteset_Map
    attr_reader :overlay

    alias _init_map_overlays initialize unless defined? _init_map_overlays
    alias _update_map_overlays update unless defined? _update_map_overlays
    alias _dispose_map_overlays dispose unless defined? _dispose_map_overlays

    def initialize(map = nil)
        @map = (map) ? map : $game_map
        @overlay = Sprite.new(@@viewport1)
        @overlay.z = OVERLAY_Z
        path = pbResolveBitmap("Graphics/Overlays/#{@map.map_id}")
        @overlay.bitmap = Bitmap.new(path) if path
        @overlay.blend_type = (RfSettings::ADDITIVE_OVERLAY_MAPS.include? @map.map_id) ? 1 : 0
        _init_map_overlays(map)
    end

    def update
        _update_map_overlays
        @overlay.x = -(@map.display_x / Game_Map::X_SUBPIXELS).round
        @overlay.y = -(@map.display_y / Game_Map::Y_SUBPIXELS).round
    end

    def dispose
        _dispose_map_overlays
        @overlay.dispose
        @overlay = nil
    end
end

# Like fogs, but global

class Spriteset_Global
    attr_reader :active_motion_overlay

    alias _init_map_overlays initialize unless defined? _init_map_overlays
    alias _update_map_overlays update unless defined? _update_map_overlays
    alias _dispose_map_overlays dispose unless defined? _dispose_map_overlays

    def initialize
        @motion_overlay = Plane.new(Spriteset_Map.viewport)
        @motion_overlay.z = MOTION_OVERLAY_Z
        _init_map_overlays
    end

    def active_motion_overlay=(name)
        return if @active_motion_overlay == name
        
        @active_motion_overlay = name
        @motion_overlay.bitmap&.dispose
        @motion_overlay.bitmap = nil
        return if @active_motion_overlay.nil?

        bmp = Bitmap.new("Graphics/Fogs/#{@active_motion_overlay}")
        @motion_overlay.bitmap = bmp if !bmp.mega?
        @motion_overlay.opacity = RfSettings::MOTION_OVERLAYS[@active_motion_overlay][:opacity] || 255
        @motion_overlay.zoom_x = RfSettings::MOTION_OVERLAYS[@active_motion_overlay][:zoom_x] || 1.0
        @motion_overlay.zoom_y = RfSettings::MOTION_OVERLAYS[@active_motion_overlay][:zoom_y] || 1.0
        @motion_overlay.blend_type = RfSettings::MOTION_OVERLAYS[@active_motion_overlay][:blend_type] || 0
    end

    def update
        _update_map_overlays
        delta_t = Graphics.delta
        if !@active_motion_overlay.nil?
            @motion_overlay.ox += RfSettings::MOTION_OVERLAYS[@active_motion_overlay][:scroll_x] * delta_t if RfSettings::MOTION_OVERLAYS[@active_motion_overlay][:scroll_x]
            @motion_overlay.oy += RfSettings::MOTION_OVERLAYS[@active_motion_overlay][:scroll_y] * delta_t if RfSettings::MOTION_OVERLAYS[@active_motion_overlay][:scroll_y]
        end
    end

    def dispose
        @motion_overlay.dispose
        _dispose_map_overlays
    end
end

EventHandlers.add(:on_map_or_spriteset_change, :change_motion_overlay,
    proc { |scene, _map_changed|
        next if !scene || !scene.spriteset
        found = false
        MOTION_OVERLAYS.each do |filename, data|
            next if !data[:maps].include?($game_map.map_id)
            found = true
            scene.spritesetGlobal.active_motion_overlay = filename
            break
        end
        scene.spritesetGlobal.active_motion_overlay = nil if !found
    }
)