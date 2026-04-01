package app.updater;

import haxe.Http;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import app.config.UpdaterConfig;
import app.util.ArtifactExtractor;

class ClientUpdater {
    public static function checkAndRelease(config:UpdaterConfig):Bool {
        var url = '${config.serverUrl}/v1/projects/${config.projectId}/builds/latest?name=${config.targetName}&platform=windows';
        trace('Checking for updates: $url');

        var request = new Http(url);
        if (config.apiKey != null) {
            request.setHeader("Authorization", 'Bearer ${config.apiKey}');
        }

        var build:Dynamic = null;
        var success = false;

        request.onData = function(data) {
            if (data == null || data == "") return;
            try {
                build = Json.parse(data);
                success = true;
            } catch (e:Dynamic) {
                trace('Error parsing latest build info: $e');
            }
        };

        request.onError = function(msg) {
            trace('Error checking for updates: $msg (continuing to launch current version)');
        };

        try {
            request.request(false);
        } catch (e:Dynamic) {
            trace('Exception during update check: $e');
            return true; // Just launch current
        }

        if (build != null && build.id != null) {
            if (build.id != config.currentBuildId) {
                trace('New version available: ${build.id} (Current: ${config.currentBuildId})');
                if (build.binaryUrl != null) {
                    return performUpdate(config, build);
                }
            } else {
                trace('Already up to date (${build.id})');
            }
        }

        return true; 
    }

    static function performUpdate(config:UpdaterConfig, build:Dynamic):Bool {
        var tempFile = "update_package.zip";
        trace('Downloading update from ${build.binaryUrl}...');

        // curl is available on Windows 10+ and almost all other modern OSs
        var proc = new sys.io.Process("curl", ["-L", "-s", "-o", tempFile, build.binaryUrl]);
        var exitCode = proc.exitCode();
        proc.close();

        if (exitCode == 0) {
            // Extract and replace
            if (ArtifactExtractor.extractZip(tempFile, ".")) {
                // Update config with new build ID
                config.currentBuildId = build.id;
                saveConfig(config);
                if (FileSystem.exists(tempFile)) FileSystem.deleteFile(tempFile);
                return true;
            }
        } else {
            trace('Download failed with curl exit code $exitCode');
        }
        
        return false;
    }

    static function saveConfig(config:UpdaterConfig) {
        try {
            File.saveContent("updater-config.json", Json.stringify(config, null, "  "));
            trace("Config updated with new build ID");
        } catch (e:Dynamic) {
            trace("Warning: Could not save updated updater-config.json: " + e);
        }
    }
}
