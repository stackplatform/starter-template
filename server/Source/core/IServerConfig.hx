package core;

import hx.injection.Service;

interface IServerConfig extends Service {
	public var protocol:String;
	public var host:String;
	public var port:Int;
	public var corsEnabled:Bool;
	public var cacheEnabled:Bool;
	public var silent:Bool;
	public var directory:String;
	public var useLime:Bool;
	public var frontendUrl:String;

	// R2 Storage Config
	public var r2AccountId:String;
	public var r2AccessKey:String;
	public var r2SecretKey:String;
	public var r2Bucket:String;
	public var r2Endpoint:String;

	// AWS/SES Config
	public var awsAccessKey:String;
	public var awsSecretKey:String;
	public var awsRegion:String;
	public var sesEnabled:Bool;

	// Platform Email Limits
	public var platformEmailRateLimit:Int;

	// Stripe Config
	public var stripeSecretKey:String;
	public var stripeWebhookSecret:String;
	public var stripeProPriceId:String;
	public var stripePremiumPriceId:String;

	// GitHub Config
	public var githubToken:String;
	public var githubAppName:String;
	public var githubAppId:String;
	public var githubPrivateKeyPath:String;
}
