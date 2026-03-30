package core;

class ServerConfig implements IServerConfig {
	public var protocol:String;
	public var host:String;
	public var port:Int;
	public var corsEnabled:Bool;
	public var cacheEnabled:Bool;
	public var silent:Bool;
	public var directory:String;
	public var useLime:Bool;
	public var frontendUrl:String;
	public var stackProjectKey:String;
	public var stackServerUrl:String;

	// R2 Storage Config
	public var r2AccountId:String;
	public var r2AccessKey:String;
	public var r2SecretKey:String;
	public var r2Bucket:String;
	public var r2Endpoint:String;

	// OAuth Config
	public var githubClientId:String;
	public var githubClientSecret:String;
	public var githubToken:String;
	public var githubAppName:String;
	public var githubAppId:String;
	public var githubPrivateKeyPath:String;

	// SES / Email Config
	public var sesEnabled:Bool;
	public var awsAccessKey:String;
	public var awsSecretKey:String;
	public var awsRegion:String;
	public var platformEmailRateLimit:Int;

	// Stripe Config
	public var stripeSecretKey:String;
	public var stripeWebhookSecret:String;
	public var stripeProPriceId:String;
	public var stripePremiumPriceId:String;

	public function new() {
		var env = loadEnv();
		protocol = "HTTP/1.1";
		host = "127.0.0.1";
		port = 8081;
		corsEnabled = true; // Enabled for direct-to-R2 flows usually
		cacheEnabled = true;
		silent = true;
		directory = null;
		useLime = false;

		// Helper to get from map or Sys.getEnv
		var get = (key:String) -> {
			if (env.exists(key)) return env.get(key);
			return Sys.getEnv(key);
		};

		if (get("PORT") != null) port = Std.parseInt(get("PORT"));
		if (get("HOST") != null) host = get("HOST");

		// Load R2 config from env
		r2AccountId = get("R2_ACCOUNT_ID");
		r2AccessKey = get("R2_ACCESS_KEY");
		r2SecretKey = get("R2_SECRET_KEY");
		r2Bucket = get("R2_BUCKET");
		if (r2AccountId != null) {
			r2Endpoint = 'https://${r2AccountId}.r2.cloudflarestorage.com';
		}

		// Load OAuth config from env
		githubClientId = get("GITHUB_CLIENT_ID");
		githubClientSecret = get("GITHUB_CLIENT_SECRET");
		githubToken = get("GITHUB_TOKEN");
		githubAppName = get("GITHUB_APP_NAME");
		githubAppId = get("GITHUB_APP_ID");
		githubPrivateKeyPath = get("GITHUB_PRIVATE_KEY_PATH");

		// Load SES / Email config
		sesEnabled = get("SES_ENABLED") == "true";
		awsAccessKey = get("AWS_ACCESS_KEY");
		awsSecretKey = get("AWS_SECRET_KEY");
		awsRegion = get("AWS_REGION") != null ? get("AWS_REGION") : "us-east-1";
		platformEmailRateLimit = get("PLATFORM_EMAIL_RATE_LIMIT") != null ? Std.parseInt(get("PLATFORM_EMAIL_RATE_LIMIT")) : 50;

		// Load Stripe config
		stripeSecretKey = get("STRIPE_SECRET_KEY");
		stripeWebhookSecret = get("STRIPE_WEBHOOK_SECRET");
		stripeProPriceId = get("STRIPE_PRO_PRICE_ID");
		stripePremiumPriceId = get("STRIPE_PREMIUM_PRICE_ID");

		if (frontendUrl == null) {
			frontendUrl = 'http://$host:$port/platform/';
		}

		stackProjectKey = get("STACK_PROJECT_KEY");
		stackServerUrl = get("STACK_SERVER_URL");
	}

	private function loadEnv():Map<String, String> {
		var env = new Map<String, String>();
		var path = ".env";
		if (!sys.FileSystem.exists(path)) {
			// Try parent directories (if running from Export/hl/bin or Export/hl)
			if (sys.FileSystem.exists("../.env")) {
				path = "../.env";
			} else if (sys.FileSystem.exists("../../.env")) {
				path = "../../.env";
			} else if (sys.FileSystem.exists("../../../.env")) {
				path = "../../../.env";
			} else if (sys.FileSystem.exists("../../../../.env")) {
				path = "../../../../.env";
			} else {
				return env;
			}
		}
		try {
			var content = sys.io.File.getContent(path);
			var lines = content.split("\n");
			for (line in lines) {
				line = StringTools.trim(line);
				if (line.length == 0 || line.charAt(0) == "#") continue;
				var parts = line.split("=");
				if (parts.length >= 2) {
					var key = StringTools.trim(parts.shift());
					var value = StringTools.trim(parts.join("="));
					// Remove quotes if present
					if (value.charAt(0) == "\"" && value.charAt(value.length - 1) == "\"") {
						value = value.substring(1, value.length - 1);
					}
					env.set(key, value);
				}
			}
		} catch (e:Dynamic) {
			// Ignore errors loading .env
		}
		return env;
	}
}
