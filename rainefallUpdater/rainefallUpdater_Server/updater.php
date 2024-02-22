<?php
    $json = file_get_contents('updater/versions.json');
    $versions = json_decode($json, true);

    $current_version = $_GET["version"];

    if (version_compare($versions["latest"], $current_version) > 0)
    {
        // create temporary update file
        $updated_files = array();
        $zipfile = new ZipArchive;
        $file_name = tempnam("tmp", "{$versions['latest']}-{$current_version}.zip");
        $zipfile->open($file_name, ZipArchive::OVERWRITE);
        foreach ($versions["manifests"] as $version)
        {
            if (version_compare($version["version"], $current_version) == 0)
            {
                break;
            }
            // add files
            foreach($version["manifest"] as $file)
            {
                if (in_array($file, $updated_files))
                {
                    continue;
                }
                $zipfile->addFile("updater/game/{$file}", $file);
                $updated_files[] = $file;
            }
        }
        $zipfile->close();
        header("Content-Type: application/zip");
        header("Content-Disposition: attachment; filename=".basename($file_name));
        header("Content-Length: " . filesize($file_name));
        readfile($file_name);
        unlink($file_name);
    }
    else
    {
        echo "latest";
    }