# rainefallUtils
Just a couple of my scripting utility functions. Required for some of my scripts to work.

`Bitmap.blur_rf(power, [opacity])` and `Bitmap.blur_fast(power, [opacity])` are functions for, well, blurring a bitmap. `Bitmap.blur_rf` is not recommended for realtime use.

`Sprite.create_outline_sprite([width])` returns a sprite intended to sit below the sprite it is called on in order to display an outline.

`Math.lerp(a, b, t)` is a simple linear interpolation function. Pokémon Essentials includes one of these now but it's more complex.

`Game_Temp.map_locked` allows you to stop the map from scrolling with the player, which is useful for allowing the player to move around in cutscenes without the camera following them. (As far as I know there is no way to do this in regular Essentials but if I'm wrong please don't tell me.)

`Rf.wait_for_move_route` is a script version of the event command of the same name. It can be used if you are writing your game events in scripts like I do sometimes. It will only work in `Scene_Map`.

`Rf.create_event` creates an event on the current map. It returns a hash containing the `Game_Event` on the map under `:event`, and the event's `Sprite_Character` under `:sprite`. It also takes a block, which allows you to modify the event before it is placed on the map, like so:
```Ruby
# creates an event
scientist_event = Rf.create_event { |event|
  # sets its properties
  event.x = 9
  event.y = 18
  event.pages[0].graphic.character_name = "scientist_m"
}

# make the event move somewhere
pbMoveRoute(scientist_event[:event], [
  PBMoveRoute::Up,
  PBMoveRoute::Up
])
Rf.wait_for_move_route

# delete the event
Rf.delete_event(scientist_event)
```

There's also `Rf.delete_event`, which you may have noticed in that code block. Mostly self explanatory, however please note it only works on events created with `Rf.create_event`.