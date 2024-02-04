# rainefallPortraits
This is a slightly less janky version of the dialogue portraits script(s) used in my games Pokémon Reflections and pre;COGNITION

## Portrait graphics
In Pokémon Reflections, portraits were 360 pixels tall and had no consistent width. The script has been modified slightly in order to allow for portraits to be any height and any width. I recommend choosing a consistent portrait size such as 192x384, and drawing your portraits centred within. Bear in mind portrait graphics are anchored to the bottom left of the screen.
*It is possible to use portraits of different sizes (Reflections does this) though it is **not recommended unless you know what you (and more importantly, the script) are doing.***

You will need to place your portrait graphics within a new directory, `Graphics/Portraits`. This directory is hardcoded in order to make referencing portrait names quicker.

## Displaying portraits
By design, the only way to set portraits is through script calls. Users of this script should have a foundational knowledge of the Ruby programming language (data types, what a function is, what an argument is) to ensure correct operation.

- To create a new portrait, call `Rf.new_portrait(“name-of-portrait-in-Graphics/Portraits”)`. Creating a new portrait automatically triggers the sliding in animation on that portrait, and will also automatically trigger the sliding out animation on and dispose the last portrait, if there is one.
- To change the graphic of the currently displayed portrait (e.g. if you want to convey a change in emotion between lines, something that was very frequently used across Reflections) use `Rf.set_portrait(“name-of-portrait-in-Graphics/Portraits”)`. Do NOT call this function without having called `Rf.new_portrait` beforehand, this will lead to undocumented behaviour (and potentially difficult to reproduce bugs! I am speaking from experience here)
- To manually call the sliding out animation on a portrait (e.g. for the end of a dialogue sequence or if there is a break in the text), use `Rf.close_portrait.`
- `Rf.new_portrait` also takes an optional argument representing where to align the portrait on the screen, `0` for left (default) and `1` for right.



## Displaying Name Labels
Reflections also used name labels above dialogue boxes if a named character was speaking. `Rf.set_speaker("speaker name")` will set the name label and `Rf.clear_speaker` will clear it.

**Remember to call `Rf.clear_speaker` or `$game_temp.speaker = nil` at the end of any events or you will end up with labels on all dialogue until $game_temp.speaker is next modified (or the game is restarted).**