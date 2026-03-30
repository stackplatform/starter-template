package app.services;

import app.models.ProjectModels.ProjectInfo;

/**
 * Internal server-side interface for calling the Stack Platform SaaS API.
 */
@:auto_client
interface IStackSaaSProjectService {
    /**
     * Fetches the current project info using the "self" magic route or a specific ID.
     * This route automatically identifies the project associated with the X-Project-Key header if "self" is used.
     */
    @get("/v1/projects/:projectId")
    public function getProjectInfo(projectId:String):ProjectInfo;
}
