module RfSettings
    OVERLAY_Z = 2500
    ADDITIVE_OVERLAY_MAPS = []

    MOTION_OVERLAY_Z = 3000
    MOTION_OVERLAYS = {
        "your_image_name_in_Graphics/Overlays_here" => {
            maps: [
                # insert map IDs here ...
            ],

            blend_type: 1,  # If this option isn't present it is assumed to be 0 (normal blending)
                            # Blend options are 0 (normal) 1 (additive) and 2 (subtractive)

            opacity: 128, # If this option isn't present it is assumed to be 255

            zoom_x: 2.0, # If this option isn't present it is assumed to be 1.0
            zoom_y: 2.0, # If this option isn't present it is assumed to be 1.0

            scroll_x: 32, # Scroll in pixels per second, can be omitted for static fogs
            scroll_y: 32  # Scroll in pixels per second, can be omitted for static fogs
        },

        "test" => {
            maps: [],
            scroll_x: 32
        }
    }
end