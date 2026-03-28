package app;

import sidewinder.core.DI;
import sidewinder.routing.Router;
import sidewinder.routing.AutoRouter;
import sidewinder.logging.HybridLogger;
import hx.injection.ServiceType;
import app.services.IProjectIntegrationService;
import app.services.ProjectIntegrationService;

/**
 * Entry point for the SideWinder-based local integration server.
 * This class handles initialization, dependency injection, and routing.
 */
class ServerApp extends core.ServerBootstrap {
    public static function main() {
        var app = new ServerApp();
        app.start();
    }

    public function new() {
        super(true); // Automatically initialize SideWinder core
    }

    /**
     * Register services with the Dependency Injection container.
     */
    override public function configureServices(services:hx.injection.ServiceCollection):Void {
        super.configureServices(services);
        
        // Register our integration service
        services.addService(ServiceType.Scoped, IProjectIntegrationService, ProjectIntegrationService);
        
        HybridLogger.info("Server Services Configured");
    }

    /**
     * Configure the HTTP routes. 
     * SideWinder's AutoRouter builds routes automatically from interface metadata.
     */
    override public function configureRoutes(router:Router):Void {
        super.configureRoutes(router);

        // Map the interface to the router
        AutoRouter.build(router, IProjectIntegrationService, () -> DI.get(IProjectIntegrationService));
        
        HybridLogger.info("Server Routes Configured via AutoRouter");
        
        // Add a simple health check
        router.add("GET", "/health", (req, res) -> {
            res.sendResponse(snake.http.HTTPStatus.OK);
            res.write("OK");
            res.end();
        });
    }

    public function start() {
        HybridLogger.info("Starting Stack Platform Starter Template Server...");
        this.init();
    }
}
