class Rfl_DialoguePortrait < Sprite
  ANIMATIONS = {
    "Kira" => {
      mouth: {
        type: :Rfl_DialoguePortrait_MouthSprite,
        bitmap_path: "Graphics/Portraits/Kira_mouth",
        frame_count: 4,
        x: 206,
        y: 352,
        animation_properties: {
          delay: 0.06
        }
      },
      eyes: {
        type: :Rfl_DialoguePortrait_EyesSprite,
        bitmap_path: "Graphics/Portraits/Kira_eyes",
        frame_count: 3,
        x: 218,
        y: 386,
        animation_properties: {
          chance: 0.008,
          delay: 0.033
        }
      }
    }
  }
  
  attr_reader :talking

  def initialize(portrait, viewport = nil)
    super(viewport)
    if DRAW_SHADOW
      @shadow_sprite = Sprite.new(viewport)
      @shadow_sprite.bitmap = Bitmap.new(256,256)
      @shadow_sprite.color = Color.new(27,31,39)
      @shadow_sprite.zoom_x = 2
      @shadow_sprite.zoom_y = 2
      @shadow_sprite.z = self.z - 1
      @shadow_sprite.opacity = 128
    end
    @animation_data = portrait.nil? ? {} : ANIMATIONS[portrait]
    @animation_sprites = {}
    @animation_states = {}
    @talking = false
    self.src_rect = Rect.new(0,0,512,512)
    return if portrait == nil
    self.bitmap = Bitmap.new("Graphics/Portraits/#{portrait}")
    setup_animations
  end

  def x=(value)
    super(value)
    @shadow_sprite&.x = value + 8
  end

  def y=(value)
    super(value)
    @shadow_sprite&.y = value + 4
  end

  def z=(value)
    super(value)
    @shadow_sprite&.z = value - 1
    @animation_sprites.each_value do |spr|
      spr.z = z
    end
  end

  def ox=(value)
    super(value)
    @shadow_sprite&.ox = value/2
  end

  def oy=(value)
    super(value)
    @shadow_sprite&.oy = value/2
  end

  def opacity=(value)
    super(value)
    @shadow_sprite&.opacity = value * 0.75
    @animation_sprites.each_value do |spr|
      spr.opacity = value
    end
  end

  def portrait=(portrait)
    self.bitmap&.dispose
    pbDisposeSpriteHash(@animation_sprites)
    @animation_states = {}

    self.bitmap = Bitmap.new("Graphics/Portraits/#{portrait}")
    if DRAW_SHADOW
      @shadow_sprite.bitmap.clear
      @shadow_sprite.bitmap.stretch_blt(@shadow_sprite.bitmap.rect,self.bitmap,self.bitmap.rect)
      @shadow_sprite.bitmap.blur(8)
    end
    @animation_data = ANIMATIONS[portrait]
    setup_animations
  end

  def visible=(visible)
    @shadow_sprite&.visible = visible
    super(visible)
  end

  def shadow_visibility=(visible)
    @shadow_visibility = visible
    @shadow_sprite&.visible = visible
  end

  def talking=(value)
    @talking = value
    @animation_sprites.each_value do |spr|
      spr.talking = value if spr.respond_to? :talking=
    end
  end

  def setup_animations
    @animation_data.each do |id, anim|
      img_path = pbResolveBitmap(anim[:bitmap_path])
      next if img_path.nil?
      sprite = Kernel.const_get(anim[:type]).new(img_path, anim[:frame_count], self.viewport)
      sprite.color = self.color
      sprite.opacity = self.opacity
      sprite.x = self.x + anim[:x]
      sprite.y = self.y - anim[:y]
      sprite.z = self.z
      anim[:animation_properties].each do |property, value|
        raise "Attempted to set animation sprite property \"#{property}\", which doesn't exist on #{sprite}" if !sprite.respond_to?(:"#{property}=")
        sprite.send(:"#{property}=", value)
      end
      @animation_sprites[id] = sprite
    end
  end
  
  def update
    super
    @animation_data.each do |id, anim|
      sprite = @animation_sprites[id]
      sprite.color = self.color
      sprite.opacity = self.opacity
      sprite.x = self.x + anim[:x] - self.ox
      sprite.y = self.y - anim[:y] - (self.oy-512)
      sprite.update
    end
  end

  def dispose
    @shadow_sprite&.dispose
    pbDisposeSpriteHash(@animation_sprites)
    super
  end
end