package core;

import hx.injection.ServiceCollection;
import sidewinder.core.DI;
import hx.injection.ServiceType;
import core.ServerConfig;
import sidewinder.interfaces.ICacheService;
import sidewinder.interfaces.InMemoryCacheService;
import sidewinder.interfaces.IDatabaseService;
import sidewinder.interfaces.ILogDatabaseService;
import sidewinder.services.SqliteDatabaseService;
import core.IServerConfig;

class ThreadBootstrap {
    public static var configureServices:(ServiceCollection) -> Void;

    public static function initThread():Void {
        DI.init(c -> {
            c.addService(ServiceType.Singleton, core.IServerConfig, core.ServerConfig);
            c.addService(ServiceType.Singleton, ICacheService, InMemoryCacheService);
            c.addService(ServiceType.Singleton, IDatabaseService, SqliteDatabaseService);
            // c.addService(ServiceType.Singleton, ILogDatabaseService, SqliteLogDatabaseService);
            
            if (configureServices != null) {
                configureServices(c);
            }
        });
    }
}
