class CrossTransceiver_Portrait < Sprite
    attr_accessor :talking

    def initialize(viewport = nil)
        super(viewport)
        @main_bmp = nil
        @eyes_bmp = nil
        @mouth_bmp = nil
        @eyes_index = 0
        @eyes_index_real = 0.0
        @mouth_index = 0
        @mouth_index_real = 0.0
        @eyes_framerate = CrossTransceiverSettings::BLINK_FRAME_RATE
        @mouth_framerate = CrossTransceiverSettings::MOUTH_RAME_RATE
        @meta = nil
        @talking = false
        @blinking = false
    end

    def setup_bi(name = nil)
        name = "soundonly" if !name
        path = pbResolveBitmap("Graphics/CrossTransceiver/Characters/#{name}")
        # Static image
        if path
            self.bitmap = Bitmap.new(path)
        else
            self.bitmap = Bitmap.new(Graphics.width/2, Graphics.height)
            @meta = parseMeta("Graphics/CrossTransceiver/Characters/#{name}")
            main_path = pbResolveBitmap("Graphics/CrossTransceiver/Characters/#{name}_main") 
            @main_bmp = Bitmap.new(main_path) if main_path
            eyes_path = pbResolveBitmap("Graphics/CrossTransceiver/Characters/#{name}_eyes") 
            @eyes_bmp = Bitmap.new(eyes_path) if eyes_path
            mouth_path = pbResolveBitmap("Graphics/CrossTransceiver/Characters/#{name}_mouth") 
            @mouth_bmp = Bitmap.new(mouth_path) if mouth_path
        end
    end

    def setup_quad(name = nil)
        name = "soundonly" if !name
        path = pbResolveBitmap("Graphics/CrossTransceiver/Characters/#{name}")
        if path
            self.bitmap = Bitmap.new(path)
            self.src_rect = Rect.new(0, self.bitmap.height / 4, self.bitmap.width, self.bitmap.height / 2)
        else
            self.bitmap = Bitmap.new(Graphics.width/2,Graphics.height/2)
            @meta = parseMeta("Graphics/CrossTransceiver/Characters/#{name}")
            main_path = pbResolveBitmap("Graphics/CrossTransceiver/Characters/#{name}_main") 
            @main_bmp = Bitmap.new(main_path) if main_path
            eyes_path = pbResolveBitmap("Graphics/CrossTransceiver/Characters/#{name}_eyes") 
            @eyes_bmp = Bitmap.new(eyes_path) if eyes_path
            mouth_path = pbResolveBitmap("Graphics/CrossTransceiver/Characters/#{name}_mouth") 
            @mouth_bmp = Bitmap.new(mouth_path) if mouth_path
        end
    end

    def update
        # do animations
        if (@talking || @mouth_index != 0) && @mouth_bmp
            @mouth_index_real += @mouth_framerate / Graphics.frame_rate
            if @mouth_index_real >= 1.0
                @mouth_index_real -= 1.0
                @mouth_index += 1
                @mouth_index -= @meta[:mouth_frames] * 2 - 2 if @mouth_index >= @meta[:mouth_frames] * 2 - 2
            end
        end
        if @blinking && @eyes_bmp
            @eyes_index_real += @eyes_framerate / Graphics.frame_rate
            if @eyes_index_real >= 1.0
                @eyes_index_real -= 1.0
                @eyes_index += 1
                if @eyes_index >= @meta[:eyes_frames] * 2 - 2
                    @eyes_index -= @meta[:eyes_frames] * 2 - 2
                    @blinking = false
                end
            end
        else
            # random chance to blink
            @blinking = rand(65536) < CrossTransceiverSettings::BLINK_RATE
        end
        redraw if @meta
    end

    def tri_wave(val, halfperiod)
        return halfperiod - (val - halfperiod).abs
    end

    def redraw
        base_y = self.bitmap.height == Graphics.height ? 0 : Graphics.height / 4
        self.bitmap.blt(0, 0, @main_bmp, Rect.new(0, base_y, self.bitmap.width, self.bitmap.height)) if @main_bmp
        self.bitmap.blt(@meta[:eyes_x], @meta[:eyes_y] - base_y, @eyes_bmp, Rect.new(tri_wave(@eyes_index, @meta[:eyes_frames]-1) * @eyes_bmp.width / @meta[:eyes_frames], 0, @eyes_bmp.width / @meta[:eyes_frames], @eyes_bmp.height)) if @eyes_bmp
        self.bitmap.blt(@meta[:mouth_x], @meta[:mouth_y] - base_y, @mouth_bmp, Rect.new(tri_wave(@mouth_index, @meta[:mouth_frames]-1) * @mouth_bmp.width / @meta[:mouth_frames], 0, @mouth_bmp.width / @meta[:mouth_frames], @mouth_bmp.height)) if @mouth_bmp
    end

    def parseMeta(path)
        meta = {}
        lines = IO.readlines(path+".meta")
        lines.each do |e|
            next if e[0] == '#'
            line = e.gsub(/\s+/, "")
            line = line.split('#')[0] # ignore comment if there is one
            if line.include? "eyes"
                line = line.split('=')[1]
                data = line.split(',')
                raise "Invalid number of metadata eyes arguments for CrossTransceiver sprite in #{path}. Expected 3, got #{data.length}" if data.length != 3
                meta[:eyes_frames] = Integer(data[0])
                meta[:eyes_x] = Integer(data[1])
                meta[:eyes_y] = Integer(data[2])
            elsif line.include? "mouth"
                line = line.split('=')[1]
                data = line.split(',')
                raise "Invalid number of metadata mouth arguments for CrossTransceiver sprite in #{path}. Expected 3, got #{data.length}" if data.length != 3
                meta[:mouth_frames] = Integer(data[0])
                meta[:mouth_x] = Integer(data[1])
                meta[:mouth_y] = Integer(data[2])
            else
                raise "Invalid metadata for CrossTransceiver sprite in #{path}"
            end
        end
        return meta
    end

    def dispose
        self.bitmap&.dispose
        @main_bmp&.dispose
        @eyes_bmp&.dispose
        @mouth_bmp&.dispose
        super
    end
end

class CrossTransceiver_Scene
    attr_accessor :call_active

    def initialize
        @interface = CrossTransceiver::Interface.new(self)
        @call = nil
        @call_active = false
        @speaker_bmp = Bitmap.new("Graphics/CrossTransceiver/speaker")
        @viewport = Viewport.new(0,0, Graphics.width, Graphics.height)
        @viewport.z = 99999


        @sprites = {}
        @sprites[:static_bg] = Sprite.new(@viewport)
        @sprites[:static_bg].zoom_x = 4
        @sprites[:static_bg].zoom_y = 2
        @sprites[:static_bg].bitmap = Bitmap.new(Settings::SCREEN_WIDTH / 4, Settings::SCREEN_HEIGHT / 2)
        @static_noise = Array.new(@sprites[:static_bg].bitmap.width * @sprites[:static_bg].bitmap.height * 4)
        (@sprites[:static_bg].bitmap.width * @sprites[:static_bg].bitmap.height).times do |i|
            base_index = i * 4
            num = rand(255)
            @static_noise[base_index] = num
            @static_noise[base_index+1] = num
            @static_noise[base_index+2] = num
            @static_noise[base_index+3] = 255
        end
        @sprites[:static_bg].bitmap.raw_data = @static_noise.pack("C*")
        @sprites[:player_bg] = Sprite.new(@viewport)
        @sprites[:player_bg].x = Graphics.width / 2
        @sprites[:caller0_bg] = Sprite.new(@viewport)
        @sprites[:caller1_bg] = Sprite.new(@viewport)
        @sprites[:caller1_bg].y = Graphics.height / 2
        @sprites[:caller1_bg].src_rect.height = Graphics.height / 2
        @sprites[:caller2_bg] = Sprite.new(@viewport)
        @sprites[:caller2_bg].y = Graphics.height / 2
        @sprites[:caller2_bg].src_rect.height = Graphics.height / 2
        @sprites[:player_portrait] = CrossTransceiver_Portrait.new(@viewport)
        @sprites[:player_portrait].x = Graphics.width / 2
        @sprites[:caller0_portrait] = CrossTransceiver_Portrait.new(@viewport)
        @sprites[:caller1_portrait] = CrossTransceiver_Portrait.new(@viewport)
        @sprites[:caller1_portrait].y = Graphics.height / 2
        @sprites[:caller2_portrait] = CrossTransceiver_Portrait.new(@viewport)
        @sprites[:caller2_portrait].y = Graphics.height / 2
        @sprites[:name_labels] = Sprite.new(@viewport)
        @sprites[:name_labels].bitmap = Bitmap.new(Graphics.width, Graphics.height)
        pbSetSystemFont(@sprites[:name_labels].bitmap)
        # this is a bit of an ugly way to set up an animated bitmap ngl
        # but i cba using anything other than mkxp's builtin one for now
        @sprites[:speaker] = Sprite.new(@viewport)
        @sprites[:speaker].bitmap = Bitmap.new(@speaker_bmp.width / 3, @speaker_bmp.height)
        3.times do |i|
            tmpbmp = Bitmap.new(@sprites[:speaker].bitmap.width, @sprites[:speaker].bitmap.height)
            tmpbmp.blt(0, 0, @speaker_bmp, Rect.new(i * @sprites[:speaker].bitmap.width, 0, @sprites[:speaker].bitmap.width, @sprites[:speaker].bitmap.height))
            @sprites[:speaker].bitmap.add_frame(tmpbmp)
            tmpbmp.dispose
        end
        @sprites[:speaker].bitmap.remove_frame(0)
        @sprites[:speaker].bitmap.frame_rate = 3
        @sprites[:speaker].bitmap.play

        # create message window
        @sprites[:message_window] = Window_AdvancedTextPokemon.new("")
        @sprites[:message_window].visible = false
        @sprites[:message_window].viewport = @viewport
        @sprites[:message_window].letterbyletter = true
        pbBottomLeftLines(@sprites[:message_window], 2)
        @sprites[:message_window].setSkin("Graphics/CrossTransceiver/windowskin")
    end

    def dispose
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
    end

    def miniupdate
        pbUpdateSpriteHash(@sprites)
        (@sprites[:static_bg].bitmap.width * @sprites[:static_bg].bitmap.height).times do |i|
            base_index = i * 4
            num = rand(255)
            @static_noise[base_index] = num
            @static_noise[base_index+1] = num
            @static_noise[base_index+2] = num
        end
        @sprites[:static_bg].bitmap.raw_data = @static_noise.pack("C*")
    end

    def setup_call(call_id)
        @call = call_id
        @call_active = true
        create_player
        create_callers
    end

    def show_call(call_id)
        setup_call(call_id)
        pbFadeInAndShow(@sprites)
        @interface.call(@call.conversation_proc)
    end

    def show_menu
        # create contact menu stuff
        pbFadeInAndShow(@sprites)
    end

    def menu_call(call_id)
        setup_call(call_id)
        # hide contact menu stuff
        @interface.call(@call.conversation_proc)
        # show contact menu stuff
    end

    def create_player
        call_mode = @call.callers.length > 1 ? :quad : :bi
        @sprites[:player_bg].bitmap = Bitmap.new get_player_backdrop
        if call_mode == :bi
            @sprites[:player_portrait].setup_bi($player.trainer_type.to_s)
        else
            @sprites[:player_portrait].setup_quad($player.trainer_type.to_s)
            @sprites[:player_bg].src_rect = Rect.new(0, @sprites[:player_bg].bitmap.height / 4, @sprites[:player_bg].bitmap.width, @sprites[:player_bg].bitmap.height / 2)
        end
    end

    def create_callers
        call_mode = @call.callers.length > 1 ? :quad : :bi
        @call.callers.each_with_index do |e, i|
            @sprites["caller#{i}_bg".to_sym].bitmap = Bitmap.new("Graphics/CrossTransceiver/Backgrounds/#{e.background_sprite}")
            if call_mode == :bi
                @sprites["caller#{i}_portrait".to_sym].setup_bi(e.character_sprite)
            else
                @sprites["caller#{i}_portrait".to_sym].setup_quad(e.character_sprite)
                @sprites["caller#{i}_bg".to_sym].src_rect = Rect.new(0, @sprites["caller#{i}_bg".to_sym].bitmap.height / 4, @sprites["caller#{i}_bg".to_sym].bitmap.width, @sprites["caller#{i}_bg".to_sym].bitmap.height / 2)
            end
        end
        draw_overlay
    end

    def get_player_backdrop
        bg = "indoor1"
        if $PokemonGlobal.surfing
            bg = water
        elsif $game_map.metadata.battle_background != nil
            bg = $game_map.metadata.battle_background
        end
        if Settings::TIME_SHADING && $game_map.metadata.outdoor_map
            timeNow = pbGetTimeNow
            if PBDayNight.isNight?(timeNow)
                bg += "_night"
            elsif PBDayNight.isEvening?(timeNow)
                bg += "_eve"
            end
        end
        bg = pbResolveBitmap("Graphics/CrossTransceiver/Backgrounds/#{bg}")
        bg = pbResolveBitmap("Graphics/CrossTransceiver/Backgrounds/indoor1") if !bg
        return bg
    end

    def draw_overlay
        @sprites[:name_labels].bitmap.clear
        @call.callers.each_with_index do |e, i|
            x = Graphics.width / 2 * i % 2
            y = (i % 2 > 0) ? (Graphics.height / 2 + 32) : 32
            pbDrawOutlineText(@sprites[:name_labels].bitmap, x, y, Graphics.width / 2, 32, e.name, Color.new(255,255,255), Color.new(0,0,0), 1)
        end
        pbDrawOutlineText(@sprites[:name_labels].bitmap, Graphics.width / 2, 32, Graphics.width / 2, 32, $player.name, Color.new(255,255,255), Color.new(0,0,0), 1)
    end

    def set_active_speaker(caller)
        @sprites[:speaker].visible = true
        @sprites[:speaker].x = (Graphics.width / 2 * caller % 2) + Graphics.width / 4 + @sprites[:name_labels].bitmap.text_size(@call.callers[caller].name).width / 2 + 32
        @sprites[:speaker].y = (caller % 2 > 0) ? (Graphics.height / 2 + 30) : 30
        @sprites["caller#{caller}_portrait".to_sym].talking = true

    end

    def set_no_speaker
        @sprites[:speaker].visible = false
        @call.callers.length.times do |i|
            @sprites["caller#{i}_portrait".to_sym].talking = false
        end
    end

    def message(text)
        # display message
        @sprites[:message_window].visible = true
        pbMessageDisplay(@sprites[:message_window], text) { miniupdate }
        @sprites[:message_window].visible = false
    end

    def message_with_branch(text, commands)
        @sprites[:message_window].visible = true
        choice = pbMessageDisplay(@sprites[:message_window], text, true, proc { |msgwindow| next Kernel.pbShowCommands(msgwindow, commands, 0, 0) { pbUpdateSpriteHash(@sprites) } }) { pbUpdateSpriteHash(@sprites) }
        @sprites[:message_window].visible = false
        return choice
    end
end

class CrossTransceiver_Screen
    def initialize(scene)
        @scene = scene
    end

    def show_menu
        @scene.show_menu
        loop do
            contact = @scene.choose_contact()
            break if contact == -1
            
            call = CrossTransceiver.get_call(contact)
            @scene.menu_call(call)
        end
        @scene.dispose
    end

    def show_call(call_id)
        @scene.show_call(call_id)
        @scene.dispose
    end
end

module CrossTransceiver
    def self.open
        pbFadeOutIn {
            scene = CrossTransceiver_Scene.new
            screen = CrossTransceiver_Screen.new(scene)
            screen.show_menu
        }
    end

    def self.call(call_id)
        call = CrossTransceiver.get_call(call_id)
        pbFadeOutIn {
            scene = CrossTransceiver_Scene.new
            screen = CrossTransceiver_Screen.new(scene)
            screen.show_call(call)
        }
    end
end