package app.models;

typedef AppConfig = {
    var api:ApiConfig;
    var ?debug:Bool;
}

typedef ApiConfig = {
    var host:String;
    var ?timeout:Int;
}
