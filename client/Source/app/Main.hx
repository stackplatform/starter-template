package app;

import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;
import app.views.DashboardView;

/**
 * Entry point for the HaxeUI-based client application.
 */
class Main {
	public static function main() {
		var app = new HaxeUIApp();
		app.ready(function() {
			// Initialize the main view
			var dashboard = new DashboardView();
			app.addComponent(dashboard);
			app.start();
		});
	}
}
