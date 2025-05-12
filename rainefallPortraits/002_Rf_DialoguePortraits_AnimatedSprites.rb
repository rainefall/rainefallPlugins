class Rfl_AnimatedSprite < Sprite
  attr_accessor :delay
  attr_accessor :animation_direction
  attr_reader :frame_count
  attr_reader :frame_index

  def initialize(bitmap_path, frame_count, viewport)
    super(viewport)
    self.bitmap = Bitmap.new(bitmap_path)
    # properties 
    @delay = 0
    @frame_count = frame_count
    @frame_index = 0
    @animation_direction = 1
    # private
    @frame_width = self.bitmap.width / frame_count
    self.src_rect.width = @frame_width
    @last_frame_update = 0
  end

  def refresh
    self.src_rect.x = @frame_index * @frame_width
  end

  def update
    return if @animation_direction.zero?
    if (System.uptime - @last_frame_update) >= @delay
      @frame_index = [[@frame_index + @animation_direction, (@frame_count-1)].min, 0].max
      @animation_direction *= -1 if @frame_index <= 0 || @frame_index >= (@frame_count-1)
      @last_frame_update = System.uptime
      refresh
    end
  end
end

class Rfl_DialoguePortrait_EyesSprite < Rfl_AnimatedSprite
  attr_accessor :chance

  def initialize(bitmap_path, frame_count, viewport)
    super(bitmap_path, frame_count, viewport)
    @chance = 0.0
  end

  def update
    if @frame_index > 0
      if (System.uptime - @last_frame_update) >= @delay
        @frame_index = (@frame_index + 1) % @frame_count
        @last_frame_update = System.uptime
        refresh
      end
    elsif (rand < @chance)
      @frame_index += 1
      @last_frame_update = System.uptime
      refresh
    end
  end
end

class Rfl_DialoguePortrait_MouthSprite < Rfl_AnimatedSprite
  attr_accessor :talking
  def update
    if @talking || @frame_index != 0
      if (System.uptime - @last_frame_update) >= @delay
        @frame_index = (@frame_index + 1) % @frame_count
        @last_frame_update = System.uptime
        refresh
      end
    end
  end
end