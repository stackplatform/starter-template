package;

import app.ServerApp;
import app.services.ProjectIntegrationService;
import sidewinder.core.DI;

class Main extends ServerApp {
	public function new(autoInit:Bool = true) {
		super(autoInit);
	}
	
	public static function main() {
		var args = Sys.args();
		trace("Main.main() args: " + args);
		
		var isSeed = false;
		for (arg in args) {
			if (arg == "--seed" || arg == "-seed") {
				isSeed = true;
				break;
			}
		}

		if (isSeed) {
			trace("Main.main() SEED MODE DETECTED!");
			var app = new Main();
			// app.minimalInitForSeeding(); 
			trace("Main.main() SEEDING COMPLETED. Exiting.");
			Sys.exit(0);
		}
		
		trace("Main.main() Normal boot mode");
		var app = new Main();
		app.exec();
	}
}
