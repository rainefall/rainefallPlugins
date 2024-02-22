module RflUpdater
    SERVER_ADDRESS = "https://your.server.ip.here"

    def self.check_for_updates
        # get rid of any leftover update files
        File.delete("#{System.data_directory}/update.rfa") if File.exist?("#{System.data_directory}/update.rfa")
        # check if the updater should actually run
        return false if !System.is_windows? || $DEBUG
        # now check for updates
        response = HTTPLite.get("#{SERVER_ADDRESS}/updater/versions.json")
        return false if response[:status] != 200
        versions = HTTPLite::JSON.parse(response[:body])
        return PluginManager.compare_versions(versions["latest"], Settings::GAME_VERSION) > 0
    end

    def self.get_latest_version_number
        response = HTTPLite.get("#{SERVER_ADDRESS}/updater/versions.json")
        return false if response[:status] != 200
        versions = HTTPLite::JSON.parse(response[:body])
        return versions["latest"] # this is horrible
    end

    def self.get_patch_notes(version=Settings::GAME_VERSION)
        response = HTTPLite.get("#{SERVER_ADDRESS}/updater/versions.json")
        return false if response[:status] != 200
        versions = HTTPLite::JSON.parse(response[:body])
        versions["manifests"].each do |v|
            return v["patch_notes"] if v["version"] == version
        end
        return nil
    end

    def self.download_update
        # download the update
        response = HTTPLite.get("#{SERVER_ADDRESS}/updater.php?version=#{Settings::GAME_VERSION}")
        if response[:status] != 200
            pbMessage(_INTL("Failed to download the update."))
            return false
        end
        File.open("#{System.data_directory}/update.rfa", "wb") do |f|
            f.write(response[:body])
        end
    end

    def self.run
        return if !RflUpdater.check_for_updates
        pbMessage(_INTL("An update is available."))
        loop do
            choice = pbMessage(_INTL("Would you like to download and install the update?"), [_INTL("Yes"), _INTL("No"), _INTL("View Patch Notes")], 2)
            case choice
            when 0
                pbMessage(_INTL("Downloading update...\\wtnp[0]"))
                RflUpdater.download_update
                yield
                Graphics.fullscreen = false
                Graphics.update
                System.launch("Updater.exe", ["#{System.data_directory}update.rfa"])
                Kernel.exit!
            when 1
                return
            when 2
                patch_notes_link = RflUpdater.get_patch_notes(RflUpdater.get_latest_version_number)
                System.launch(patch_notes_link) if !patch_notes_link.nil?
            end
        end
    end
end