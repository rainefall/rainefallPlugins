class Spriteset_Global
  alias rf_portraits_init initialize
  alias rf_portraits_update update

  attr_accessor :activePortrait

  def initialize
      rf_portraits_init
      @activePortrait = nil
      @oldPortrait = nil
  end

  def newPortrait(portrait, align = 0)
      @oldPortrait = @activePortrait
      @oldPortrait&.state = :closing
      @activePortrait = RfDialoguePortrait.new(portrait, align, @@viewport2)
  end

  def update
      rf_portraits_update
      @activePortrait&.update
      @oldPortrait&.update
  end

  def self.viewport
      return @@viewport2
  end
end

module Rf
  @@name_window_skin = RfSettings::DEFAULT_WINDOW_SKIN
  def self.name_window_skin
      return @@name_window_skin ? @@name_window_skin : MessageConfig.pbGetSystemFrame
  end

  # override the windowskin used for the namewindow
  def self.name_window_skin=(skin)
      @@name_window_skin = skin ? skin : RfSettings::DEFAULT_WINDOW_SKIN
  end

  @@outline_colour = RfSettings::DEFAULT_OUTLINE_COLOR
  def self.portrait_outline_color
      return @@outline_colour
  end

  # override the colour used for portrait outlines
  def self.portrait_outline_color=(color)
      @@outline_colour = color ? color : RfSettings::DEFAULT_OUTLINE_COLOR
  end

  # set the active dialogue portrait and trigger the portrait opening animation
  # portrait is the name of a portrait graphic in Graphics/Portraits (ANIMATED GIFS ARE NOT SUPPORTED)
  def self.new_portrait(portrait, align = 0)
      $scene.spritesetGlobal.newPortrait(portrait, align) if $scene.is_a? Scene_Map
  end

  # set the active dialogue portrait and trigger the portrait "switching" animation
  # portrait is the name of a portrait graphic in Graphics/Portraits (ANIMATED GIFS ARE NOT SUPPORTED)
  def self.set_portrait(portrait)
      $scene.spritesetGlobal.activePortrait&.portrait = portrait if $scene.is_a? Scene_Map
  end

  def self.close_portrait
      $scene.spritesetGlobal.activePortrait&.state = :closing if $scene.is_a? Scene_Map
  end

  # slightly more readable way of suppressing player portrait on next showCommands
  def self.no_player_portrait
      $game_temp.player_portrait_disabled = true
  end

  # slightly more readable ways of setting the name label
  def self.set_speaker(name)
      $game_temp.speaker = name
  end
  def self.clear_speaker
      $game_temp.speaker = nil
  end
end

class Game_Temp
  attr_accessor :speaker
  attr_accessor :player_portrait_disabled # it may be bad practice to not initialize this variable but i'm also not sure if it matters like at all
end

if RfSettings::PORTRAITS_ENABLE_CAVEOVERLAY_FIX
  EventHandlers.remove(:on_map_or_spriteset_change, :show_darkness)
  EventHandlers.add(:on_map_or_spriteset_change, :show_darkness,
  proc { |scene, _map_changed|
      next if !scene || !scene.spriteset
      map_metadata = $game_map.metadata
      if map_metadata&.dark_map
          $game_temp.darkness_sprite = DarknessSprite.new(Spriteset_Map.viewport)
          scene.spriteset.addUserSprite($game_temp.darkness_sprite)
          if $PokemonGlobal.flashUsed
          $game_temp.darkness_sprite.radius = $game_temp.darkness_sprite.radiusMax
          end
      else
          $PokemonGlobal.flashUsed = false
          $game_temp.darkness_sprite&.dispose
          $game_temp.darkness_sprite = nil
      end
      }
  )
end