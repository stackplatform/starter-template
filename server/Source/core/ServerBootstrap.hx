package core;

import sidewinder.interfaces.IWebServer;
import sidewinder.core.WebServerFactory;
import sidewinder.routing.SideWinderRequestHandler;
import hx.injection.ServiceCollection;
import sidewinder.core.DI;
import sidewinder.logging.HybridLogger;
import sidewinder.interfaces.InMemoryCacheService;
import sidewinder.interfaces.ICacheService;
import sidewinder.interfaces.IDatabaseService;
import sidewinder.interfaces.ILogDatabaseService;
import sidewinder.services.SqliteDatabaseService;
import lime.app.Application;
import lime.ui.WindowAttributes;
import lime.ui.Window;
import sys.net.Host;
import sidewinder.routing.Router;
import snake.http.BaseHTTPRequestHandler;
import hx.injection.ServiceType;
import sidewinder.interfaces.IslandManager;

class ServerBootstrap extends Application {
	public var config:ServerConfig;
	public var httpServer:IWebServer;
	public var router:Router;
	public var cache:ICacheService;

	public function new(autoInit:Bool = true) {
		super();
		config = new ServerConfig();
		// Allow subclasses to modify config before init
		configure();
		if (autoInit)
			init();
	}

	public function configure():Void {
		// Override in subclass
	}

	public function init():Void {
		HybridLogger.init();
		HybridLogger.addProvider(new sidewinder.logging.ConsoleLogProvider());
		//HybridLogger.addprovider(new sidewinder.logging.SqliteLogProvider());

		// Configure SideWinderRequestHandler
		BaseHTTPRequestHandler.protocolVersion = config.protocol;
		SideWinderRequestHandler.corsEnabled = config.corsEnabled;
		SideWinderRequestHandler.cacheEnabled = config.cacheEnabled;
		SideWinderRequestHandler.silent = config.silent;

		router = SideWinderRequestHandler.router;

		// DI Initialization for the main thread
		ThreadBootstrap.configureServices = configureServices;
		ThreadBootstrap.initThread();

		// Run migrations once on the main thread
		DI.get(IDatabaseService).runMigrations();
		// DI.get(ILogDatabaseService).runMigrations(); // Commented out if not available

		afterMigrations();

		cache = DI.get(ICacheService);

		// Configure generic middleware/routes
		configureMiddleware();
		configureRoutes(router);

		// Start Web Server
		var serverType = config.useLime ? sidewinder.core.WebServerType.SnakeServer : sidewinder.core.WebServerType.HxWell;

		// Setup worker islands with thread bootstrap hook
		var numIslandsStr = Sys.getEnv("SIDEWINDER_ISLANDS");
		var numIslands = numIslandsStr != null ? Std.parseInt(numIslandsStr) : 4;
		if (numIslands == null || numIslands < 1)
			numIslands = 4;

		var islandManager = new IslandManager(numIslands, ThreadBootstrap.initThread);
		httpServer = WebServerFactory.create(serverType, config.host, config.port, SideWinderRequestHandler, config.directory, islandManager);
		httpServer.start();
	}

	public function configureServices(services:ServiceCollection):Void {
		services.addConfig(config);
		services.addService(core.IServerConfig, cast config);

		// SideWinder core services
		services.addService(ServiceType.Singleton, sidewinder.interfaces.ICacheService, sidewinder.interfaces.InMemoryCacheService);
		services.addService(ServiceType.Singleton, sidewinder.interfaces.IJobStore, sidewinder.interfaces.InMemoryJobStore);
		services.addService(ServiceType.Singleton, sidewinder.interfaces.IStreamBroker, sidewinder.messaging.LocalStreamBroker);
		services.addService(ServiceType.Singleton, sidewinder.interfaces.IMessageBroker, sidewinder.messaging.PollingMessageBroker);
	}

	public function configureMiddleware():Void {
		// Override in subclass
	}

	public function configureRoutes(router:Router):Void {
		// Override in subclass
	}

	public function afterMigrations():Void {
		// Override in subclass
	}

	public override function onWindowCreate():Void {
		// Lime-specific start if needed
	}
}
