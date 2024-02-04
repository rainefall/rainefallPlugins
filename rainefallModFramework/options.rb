module ModLoader
    # This is a list of paths/files that are part of your game's standard path cache
    # The modloader will (attempt to) unmount these before it loads mods
    # then remount them after it has loaded all mods
    # This has to be done as the earlier a path is mounted the higher its priority
    BASE_PATHS = [
        ".", # To mimic the unmodified behaviour, this entry should remain at the top.
        "Game.rgssad"
    ]
end