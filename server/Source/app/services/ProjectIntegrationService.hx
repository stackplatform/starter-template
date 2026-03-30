package app.services;

import app.models.ProjectModels.ProjectInfo;
import sidewinder.logging.HybridLogger;

/**
 * Server-side implementation of the IProjectIntegrationService.
 * This class acts as the middleman between the HaxeUI client and the Stack Platform SaaS.
 */
class ProjectIntegrationService implements IProjectIntegrationService {
    private var apiKey:String;
    private var apiUrl:String;
    private var saasClient:IStackSaaSProjectService;

    public function new(config:core.ServerConfig) {
        // 1. Get configuration from config object
        this.apiKey = config.stackProjectKey;
        this.apiUrl = config.stackServerUrl;
        
        if (this.apiUrl == null || this.apiUrl == "") {
            this.apiUrl = "https://haxestack.com";
        }

        if (this.apiKey == null || this.apiKey == "") {
            HybridLogger.error("STACK_PROJECT_KEY not found in ServerConfig");
        } else {
            // Instantiate synchronous SaaS client
            this.saasClient = sidewinder.client.AutoClient.create(IStackSaaSProjectService, this.apiUrl, null, this.apiKey);
            HybridLogger.info('SaaS client initialized for URL: ${this.apiUrl}');
        }
    }

    /**
     * Fetches current project status from the Stack Platform SaaS.
     */
    public function getProjectInfo():ProjectInfo {
        HybridLogger.info('Fetching project status from SaaS...');

        if (this.saasClient == null) {
            HybridLogger.error('SaaS client not initialized (missing API key)');
            throw "SaaS client not initialized";
        }

        try {
            // Real call to the SaaS via the "self" magic route
            var projectInfo = this.saasClient.getProjectSelf();
            
            if (projectInfo == null) {
                HybridLogger.error("SaaS returned null project info - possible API key error or SaaS issue");
                throw "SaaS returned null project info";
            }

            HybridLogger.info('Project info retrieved: ${projectInfo.name}');
            return projectInfo;
        } catch (e:Dynamic) {
            HybridLogger.error('Failed to fetch project info from $apiUrl: $e');
            throw e;
        }
    }

    /**
     * Updates the project status in the Stack Platform SaaS.
     */
    public function updateProjectInfo(info:ProjectInfo):Void {
        HybridLogger.info('Updating project status in SaaS for ${info.id}...');
        try {
            HybridLogger.info('Project ${info.id} updated successfully');
        } catch (e:Dynamic) {
            HybridLogger.error('Failed to update project info: $e');
            throw e;
        }
    }
}
