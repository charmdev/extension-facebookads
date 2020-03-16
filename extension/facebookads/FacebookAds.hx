package extension.facebookads;

import nme.JNI;
import nme.Lib;

class FacebookAds {

	#if ios
	private static var __ads_set_event_handle = Lib.load("facebookadsex","ads_set_event_handle", 1);
	public static var __reloadRewarded:Void->Void = function() {}
	#end

	private static var initialized:Bool = false;
	private static var testingAds:Bool = false;
	public static var __showRewarded:Void->Void = function() {}
	private static var completeCB;
	private static var skipCB;
	private static var canshow:Bool = false;

	public static function enableTestingAds() {
		if ( testingAds ) return;
		if ( initialized ) {
			var msg:String;
			msg = "FATAL ERROR: If you want to enable Testing Ads, you must enable them before calling INIT!.\n";
			msg+= "Throwing an exception to avoid displaying read ads when you want testing ads.";
			trace(msg);
			throw msg;
			return;
		}
		testingAds = true;
	}

	public static function init(rewardedID:String) {
		if(initialized) return;
		initialized = true;
		#if android
			try {
				var __init:Bool->FacebookAds->String->Void =
				JNI.createStaticMethod("org/haxe/extension/facebookAds/FacebookAds", "init", "(ZLorg/haxe/lime/HaxeObject;Ljava/lang/String;)V");
				__showRewarded = JNI.createStaticMethod("org/haxe/extension/facebookAds/FacebookAds", "showRewarded", "()V");
				__init(testingAds, new FacebookAds(), rewardedID);

			} catch(e:Dynamic) {
				trace("Error: "+e);
			}
		#elseif ios
			try{
				var __init:String->Bool->Void = cpp.Lib.load("facebookAdsEx","facebookadsex_init",2);
				__showRewarded = cpp.Lib.load("facebookAdsEx","facebookadsex_show_rewarded",0);
				__reloadRewarded = cpp.Lib.load("facebookAdsEx","facebookadsex_reload_rewarded",0);
				__init(rewardedID,testingAds);

				__ads_set_event_handle(notifyListeners);
			}catch(e:Dynamic){
				trace("iOS INIT Exception: "+e);
			}
		#end
	}

	public static function canShowAds():Bool {
		#if ios
		if (!canshow) __reloadRewarded();
		#end
		return canshow;
	}

	public static function showRewarded(cb, skip) {
		
		canshow = false;

		trace("try... showRewarded fb");

		completeCB = cb;
		skipCB = skip;

		try {
			__showRewarded();
		} catch(e:Dynamic) {
			trace("ShowRewarded Exception: " + e);
		}
	}

	#if ios
	private static function notifyListeners(inEvent:Dynamic)
	{
		var event:String = Std.string(Reflect.field(inEvent, "type"));

		if (event == "rewardedcanshow")
		{
			canshow = true;
			trace("REWARDED CAN SHOW");
		}
		else  if (event == "rewardedcompleted")
		{
			trace("REWARDED COMPLETED");
			if (completeCB != null) completeCB();

			__reloadRewarded();
		}
		else if (event == "rewardedskipped")
		{
			trace("VIDEO IS SKIPPED");
			if (skipCB != null) skipCB();

			__reloadRewarded();
			
		}
	}
	#elseif android

	private function new() {}

	public function onRewardedCanShow()
	{
		canshow = true;
		trace("REWARDED CAN SHOW");
	}

	public function onRewardedCompleted()
	{
		trace("REWARDED COMPLETED");
		if (completeCB != null) completeCB();
	}
	public function onVideoSkipped()
	{
		trace("VIDEO IS SKIPPED");
		if (skipCB != null) skipCB();
	}
	
	#end
}
