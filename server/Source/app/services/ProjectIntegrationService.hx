package app.services;

import app.models.ProjectModels.ProjectInfo;
import stack.sdk.StackClient;
import sidewinder.logging.HybridLogger;

/**
 * Server-side implementation of the IProjectIntegrationService.
 * This class acts as the middleman between the HaxeUI client and the Stack Platform SaaS.
 * Now refactored to use the official Stack Platform SDK.
 */
class ProjectIntegrationService implements IProjectIntegrationService {
    private var sdk:StackClient;

    public function new() {
        // 1. Get configuration from environment
        var apiKey = Sys.getEnv("STACK_PROJECT_API_KEY");
        var apiUrl = Sys.getEnv("STACK_PLATFORM_URL");
        
        if (apiUrl == null || apiUrl == "") {
            apiUrl = "https://api.stackplatform.com";
        }

        if (apiKey == null || apiKey == "") {
            HybridLogger.error("STACK_PROJECT_API_KEY not found in environment variables");
            // In a real app, we might handle this more gracefully, 
            // but for a starter template, a clear error is best.
        }

        // 2. Initialize the SDK Client
        this.sdk = new StackClient(apiUrl, apiKey);
    }

    /**
     * Fetches current project status from the Stack Platform SaaS using the SDK.
     */
    public function getProjectInfo():ProjectInfo {
        HybridLogger.info('Fetching project status from SaaS via SDK...');

        try {
            // 3. Use the type-safe SDK to fetch project info
            // The 'current' project is determined by the API Key used in the client.
            var project = sdk.project.getProject("current");

            if (project == null) {
                throw "Integration Error: Project not found or API key invalid";
            }

            // 4. Map the SDK model to our template's internal ProjectInfo DTO
            return {
                id: project.id,
                name: project.name,
                status: project.isActive ? "Active" : "Inactive",
                lastSync: Date.now(),
                saasUrl: 'https://app.stackplatform.com/projects/${project.id}'
            };

        } catch (e:Dynamic) {
            HybridLogger.error('Exception during SDK request: $e');
            throw "Integration Error: Failed to reach Stack Platform via SDK";
        }
    }
}
