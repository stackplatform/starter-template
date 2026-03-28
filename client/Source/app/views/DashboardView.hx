package app.views;

import haxe.ui.containers.VBox;
import app.services.IProjectIntegrationService;
import app.models.ProjectModels.ProjectInfo;
import sidewinder.client.AutoClientAsync;

/**
 * Controller for the Dashboard View.
 * Demonstrates calling the local server via AutoClientAsync.
 */
@:build(haxe.ui.ComponentBuilder.build("Assets/dashboard.xml"))
class DashboardView extends VBox {
    public function new() {
        super();
        
        // Connect to the local integration server
        var serverUrl = "http://localhost:8081";
        var client = AutoClientAsync.create(IProjectIntegrationService, serverUrl);

        // Fetch project info when the view is created
        refreshProject(client);
        
        // Setup manual refresh button (defined in XML)
        this.findComponent("refreshBtn", haxe.ui.components.Button).onClick = function(_) {
            refreshProject(client);
        };
    }

    private function refreshProject(client:Dynamic) {
        var statusLabel = this.findComponent("statusLabel", haxe.ui.components.Label);
        var projectLabel = this.findComponent("projectLabel", haxe.ui.components.Label);
        
        statusLabel.text = "Fetching project info...";
        
        // Type-safe async call to our local server
        client.getProjectInfoAsync(function(info:ProjectInfo) {
            projectLabel.text = info.name;
            statusLabel.text = "Status: " + info.status + " (Last Sync: " + info.lastSync + ")";
        }, function(error:String) {
            statusLabel.text = "Error: " + error;
        });
    }
}
