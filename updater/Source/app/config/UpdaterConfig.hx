package app.config;

typedef UpdaterConfig = {
    var serverUrl:String;
    var projectId:String;
    var targetName:String;          // e.g. "client"
    var targetExecutable:String;    // e.g. "Export/hl/bin/Client.exe"
    @:optional var currentBuildId:String;
    @:optional var projectApiKey:String;
}
