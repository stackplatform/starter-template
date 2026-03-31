package app.services;

import haxe.Http;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import app.models.ConfigModels.AppConfig;
import json2object.JsonParser;

class ConfigService {
	public static var instance(get, null):ConfigService;

	private static function get_instance():ConfigService {
		if (instance == null)
			instance = new ConfigService();
		return instance;
	}

	public var config(default, null):AppConfig;

	public function new() {}

	/**
	 * Loads the configuration synchronously.
	 */
	public function load():Void {
		var content:String = "";

		#if sys
		// 1. Try local override file (next to the executable)
		var localPath = "config.json";
		if (FileSystem.exists(localPath)) {
			trace("Loading local config override from: " + localPath);
			content = File.getContent(localPath);
		}
		#end

		// 2. Fallback to bundled asset if no local override or it failed
		if (content == "") {
			trace("Loading bundled config asset...");
			try {
				content = openfl.utils.Assets.getText("Assets/config.json");
			} catch (e:Dynamic) {
				trace("Error loading bundled config: " + e);
			}
		}

		if (content == "") {
			// Default fallback if everything fails
			config = {
				api: {
					host: "http://localhost:8082",
					timeout: 10000
				},
				debug: true
			};
			return;
		}

		try {
			var parser = new JsonParser<AppConfig>();
			parser.fromJson(content, "config.json");
			if (parser.errors.length > 0) {
				trace("Errors parsing config.json:");
				for (err in parser.errors) {
					trace("  " + json2object.ErrorUtils.convertError(err));
				}
			}
			config = parser.value;
		} catch (e:Dynamic) {
			trace("Critical error parsing config.json: " + e);
			// Fallback
			config = {
				api: {
					host: "http://localhost:8082",
					timeout: 10000
				}
			};
		}
	}
}
