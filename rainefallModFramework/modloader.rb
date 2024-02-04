module ModLoader
    @@mods = []

    def self.load_mods
        # unmount the original path cache so that mod assets take priority
        BASE_PATHS.each { |path| System.unmount(path) if FileTest.exist?(path) || FileTest.directory?(path) }

        # load mods
        Dir.get("Mods").each do |e|
            load_mod(e) if FileTest.directory?(e)
        end

        # re-mount the original path cache
        BASE_PATHS.each { |path| System.mount(path) if FileTest.exist?(path) || FileTest.directory?(path) }
    end

    def self.load_mod(path)
        return ModLoader.modloader_error("Error in #{path}: mod.json not found") if !FileTest.exist?("#{path}/mod.json")
        @@mods << HTTPLite::JSON.parse(IO.read("#{path}/mod.json"))
        # mount assets
        System.mount("#{path}/assets") if FileTest.directory?("#{path}/assets")
        # load scripts
        if FileTest.directory?("#{path}/scripts")
            Dir.get("#{path}/scripts").each do |script_file|
                eval(IO.read(script_file), TOPLEVEL_BINDING, path)
            end
        end
    end

    def initialize(path, modjson)
        @metadata = HTTPLite::JSON.parse(modjson)
    end

    def modloader_error(error_text)
        Console.echo_error(error_text)
        return false
    end
end

module Game
    unless defined?(__initialize_ModLoader)
        class << Game
            alias __initialize_ModLoader initialize
        end
    end

    def self.initialize
        ModLoader.load_mods
        __initialize_ModLoader
    end
end