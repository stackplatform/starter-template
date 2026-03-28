package app.services;

import app.models.ProjectModels.ProjectInfo;

/**
 * Service interface defining the contract between the local server and the client.
 * Using SideWinder's @:auto_client metadata to enable automatic type-safe client generation.
 */
@:auto_client
interface IProjectIntegrationService {
    /**
     * Retrieves the current project information from the local server.
     * The local server acts as an integration layer by calling the Stack Platform SaaS.
     * 
     * @get("/api/project")
     */
    public function getProjectInfo():ProjectInfo;
}
