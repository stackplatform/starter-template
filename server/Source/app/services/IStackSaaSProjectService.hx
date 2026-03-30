package app.services;

import app.models.ProjectModels.ProjectInfo;

/**
 * Internal server-side interface for calling the Stack Platform SaaS API.
 */
@:auto_client
interface IStackSaaSProjectService {
    /**
     * Fetches the current project info using the "self" magic route.
     * This route automatically identifies the project associated with the X-Project-Key header.
     */
    @get("/api/projects/self")
    public function getProjectSelf():ProjectInfo;
}
