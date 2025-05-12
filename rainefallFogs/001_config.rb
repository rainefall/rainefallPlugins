module RfSettings
  # Rate at which the fog scrolls when the player walks/camera moves
  FOG_PARALLAX = 1

  # MapID => Blend mode (0 for normal, 1 for additive, 2 for subtractive)
  OVERLAY_BLEND_MODES = {
    # 4 => 1,
    # 3 => 2
  }
  # Default overlay blend mode is normal, you can change this if you want
  OVERLAY_BLEND_MODES.default = 0

  # accessibility features
  ADD_FOGS_TO_SETTINGS = true
  SETTINGS_AFFECT_FOGS = true
  SETTINGS_AFFECT_GLOBAL_OVERLAY = true
  SETTINGS_MAP_OVERLAY_OPACITY = 160

  # ===========================================================================
  # Do not edit beyond this point!!!!
  # ===========================================================================

  raise "Invalid default value nil for RfSettings::OVERLAY_BLEND_MODES (0, 1 or 2 accepted)" if OVERLAY_BLEND_MODES.default.nil?
  raise "Invalid default value #{OVERLAY_BLEND_MODES.default} for RfSettings::OVERLAY_BLEND_MODES (0, 1 or 2 accepted)" if !OVERLAY_BLEND_MODES.default.is_a?(Integer) || (OVERLAY_BLEND_MODES.default > 2 || OVERLAY_BLEND_MODES.default < 0)
end