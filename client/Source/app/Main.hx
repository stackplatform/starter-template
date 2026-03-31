package app;

import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;
import app.views.DashboardView;

/**
 * Entry point for the HaxeUI-based client application.
 */
class Main {
	public static function main() {
		var uiApp = new HaxeUIApp();
		uiApp.ready(function() {
			// Load configuration
			app.services.ConfigService.instance.load();
			var config = app.services.ConfigService.instance.config;
			trace("Application starting with API host: " + config.api.host);

			// Initialize the main view
			var dashboard = new DashboardView();
			uiApp.addComponent(dashboard);
			uiApp.start();
		});
	}
}
