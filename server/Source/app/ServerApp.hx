package app;

import sidewinder.routing.Router;
import sidewinder.routing.AutoRouter;
import sidewinder.logging.HybridLogger;
import app.services.IProjectIntegrationService;
import app.services.ProjectIntegrationService;
import hx.injection.ServiceCollection;
import snake.http.HTTPStatus;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

/**
 * Entry point for the SideWinder-based local integration server.
 * This class handles initialization and routing.
 */
class ServerApp extends core.ServerBootstrap {
    private var integrationService:ProjectIntegrationService;
    
    public function new(autoInit:Bool = true) {
        super(autoInit);
    }

    override public function configure():Void {
        super.configure();
        this.integrationService = new ProjectIntegrationService(config);
        
        var staticDir = "static";
        if (!FileSystem.exists(staticDir)) {
            if (FileSystem.exists("../../static")) {
                staticDir = "../../static";
            }
        }

        try {
            var fullPath = FileSystem.fullPath(staticDir);
            config.directory = fullPath.split("\\").join("/");
        } catch (e:Dynamic) {
            config.directory = staticDir;
        }
    }

    override public function configureServices(services:ServiceCollection):Void {
        super.configureServices(services);
        // Register any additional services here
    }

    /**
     * Configure the HTTP routes.
     */
    override public function configureRoutes(router:Router):Void {
        super.configureRoutes(router);
        
        // Map the interface to the router
        AutoRouter.build(router, IProjectIntegrationService, () -> integrationService);
        
        HybridLogger.info("Server Routes Configured via AutoRouter");
        
        // Add a simple health check
        router.add("GET", "/health", (req, res) -> {
            res.sendResponse(HTTPStatus.OK);
            res.write("OK");
            res.end();
        });

        // Platform UI Static Routes
        router.add("GET", "/platform/", (req, res) -> {
            servePlatformFile("index.html", res);
        });
        router.add("GET", "/platform", (req, res) -> {
            res.sendResponse(HTTPStatus.MOVED_PERMANENTLY);
            res.setHeader("Location", "/platform/");
            res.end();
        });
        router.add("GET", "/platform/*", (req, res) -> {
            var path = req.path.substring("/platform/".length);
            servePlatformFile(path, res);
        });
    }

    private function servePlatformFile(path:String, res:sidewinder.routing.Response):Void {
        var staticDir = "static/platform";
        // Check relative path from binary or project root
        var fullPath = FileSystem.exists(staticDir) ? '$staticDir/$path' : '../../static/platform/$path';
        if (!FileSystem.exists(fullPath)) {
            // Try bin relative if not found
            fullPath = 'static/platform/$path';
        }

        if (FileSystem.exists(fullPath) && !FileSystem.isDirectory(fullPath)) {
            var ext = Path.extension(fullPath).toLowerCase();
            var contentType = switch(ext) {
                case "html": "text/html";
                case "js": "application/javascript";
                case "css": "text/css";
                case "png": "image/png";
                case "jpg" | "jpeg": "image/jpeg";
                case "svg": "image/svg+xml";
                case "json": "application/json";
                default: "application/octet-stream";
            }
            
            try {
                var content = File.getContent(fullPath);
                res.sendResponse(HTTPStatus.OK);
                res.setHeader("Content-Type", contentType);
                res.endHeaders();
                res.write(content);
                res.end();
            } catch (e:Dynamic) {
                HybridLogger.error('Error serving $fullPath: $e');
                res.sendResponse(HTTPStatus.INTERNAL_SERVER_ERROR);
                res.endHeaders();
                res.write("Error serving file");
                res.end();
            }
        } else {
            res.sendResponse(HTTPStatus.NOT_FOUND);
            res.endHeaders();
            res.write("Platform file not found: " + path);
            res.end();
        }
    }
}
