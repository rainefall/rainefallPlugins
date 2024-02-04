# rainefallFogs
Replacement for RPG Maker XP's fog system allowing for better lighting effects and consistent fogs across map connections.

rainefallFogs separates the two uses of fogs into two systems, "Overlays" and "Motion Overlays". The separation of the two means you can now have maps with lighting and shading as well as a scrolling fog effect.

## Overlays
Overlays are your lighting, shading, and any details you want to add to a map that would be cumbersome to add with tiles. These overlays are created per map and don't repeat, allowing complex lighting and shading effects in games that make heavy use of map connections.

### Usage
To add an overlay to a map, simply create a folder in your game's Graphics folder called "Overlays", and place your overlays in there. The title must match the map ID of the map that the overlay is for, and the script will automatically add an overlay to any map with a corresponding overlay image in the overlays folder. No need for events!

## Motion Overlays
Motion overlays are your traditional fogs, with a few advantages over the built in fog system (faster/setup, no more pop in on map connections).

### Usage
To add a motion overlay, the process is a little bit more complicated.
Observe the example motion overlays hash in config.rb

## Limitations
Overlays are very large images that some weaker/mobile GPUs may not be able to display.