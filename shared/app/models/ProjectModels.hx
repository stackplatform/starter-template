package app.models;

import Date;

/**
 * Simplified project information DTO.
 * This model is shared between the local server and the client.
 */
typedef ProjectInfo = {
    /** Unique identifier for the project */
    var id:String;
    
    /** Human-readable name */
    var name:String;
    
    /** Current project status (e.g. Active, Inactive, Maintenance) */
    var status:String;
    
    /** The timestamp of the last successful sync with Stack Platform SaaS */
    var lastSync:Date;
    
    /** Optional URL to the project's dashboard in the SaaS */
    var ?saasUrl:String;
}
