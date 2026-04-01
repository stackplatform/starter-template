package;

import app.config.UpdaterConfig;
import app.updater.ClientUpdater;
import haxe.Http;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
using StringTools;

class UpdaterApp {
    public static var config:UpdaterConfig;

    static function main() {
        trace("Starting Stack Client Updater...");

        // Load configuration
        var configPath = "updater-config.json";
        var args = Sys.args();
        if (args.length > 0 && !args[0].startsWith("-")) {
            configPath = args[0];
        }

        if (!FileSystem.exists(configPath)) {
            trace("Error: Configuration file not found at " + configPath);
            trace("You should provide an updater-config.json in the current directory.");
            Sys.exit(1);
        }

        try {
            var content = File.getContent(configPath);
            config = Json.parse(content);
        } catch (e:Dynamic) {
            trace("Error parsing configuration: " + e);
            Sys.exit(1);
        }

        // Check and update
        var updated = ClientUpdater.checkAndRelease(config);
        
        // Launch the client
        launchClient();
    }

    static function launchClient() {
        if (!FileSystem.exists(config.targetExecutable)) {
            trace("Error: Client executable not found at: " + config.targetExecutable);
            Sys.exit(1);
        }

        trace("Launching client: " + config.targetExecutable);
        
        var target = config.targetExecutable;
        if (Sys.systemName() == "Windows") {
            Sys.command('start "" "$target"');
        } else {
            Sys.command('./$target &');
        }

        trace("Updater shutting down.");
        Sys.exit(0);
    }
}
