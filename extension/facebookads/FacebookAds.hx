﻿package extension.facebookads;

import nme.JNI;
import nme.Lib;

class FacebookAds {

#if ios
	private static var __fbads_set_event_handle = Lib.load("facebookadsex","fbads_set_event_handle", 1);
	public static var __reloadRewarded:Void->Void = function() {}
	public static var __setAdvertiserTrackingEnabled:Void->Void = function() {}
	public static var __setAdvertiserTrackingEnabledNO:Void->Void = function() {}
#end

	private static var initialized:Bool = false;
	private static var testingAds:Bool = false;
	public static var __showRewarded:Void->Void = function() {}
	private static var completeCB:Void->Void;
	private static var skipCB:Void->Void;
	private static var viewCB:Void->Void;
	private static var clickCB:Void->Void;
	private static var canshow:Bool = false;
	public static var onRewardedEvent:String->Void = null;

#if android
	private static var instance:FacebookAds = new FacebookAds();
#end

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

				__init(testingAds, instance, rewardedID);

			} catch(e:Dynamic) {
				trace("Error: "+e);
			}
#elseif ios
			try{
				var __init:String->Bool->Void = cpp.Lib.load("facebookAdsEx","facebookadsex_init",2);
				__showRewarded = cpp.Lib.load("facebookAdsEx","facebookadsex_show_rewarded",0);
				__setAdvertiserTrackingEnabled = cpp.Lib.load("facebookAdsEx","facebookadsex_setAdvertiserTrackingEnabled",0);
				__setAdvertiserTrackingEnabledNO = cpp.Lib.load("facebookAdsEx","facebookadsex_setAdvertiserTrackingEnabled_no",0);
				__reloadRewarded = cpp.Lib.load("facebookAdsEx","facebookadsex_reload_rewarded",0);
				__init(rewardedID,testingAds);

				__fbads_set_event_handle(notifyListeners);
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

	public static function showRewarded(cb, skip, displaying, click) {
		
		canshow = false;

		trace("try... showRewarded fb");

		completeCB = cb;
		skipCB = skip;
		viewCB = displaying;
		clickCB = click;

		try {
			__showRewarded();
		} catch(e:Dynamic) {
			trace("ShowRewarded Exception: " + e);
		}
	}

#if ios
	public static function setAdvertiserTrackingEnabled() {
		try {
			__setAdvertiserTrackingEnabled();
		} catch(e:Dynamic) {
			trace("setAdvertiserTrackingEnabled Exception: " + e);
		}
	}

	public static function setAdvertiserTrackingEnabledNO() {
		try {
			__setAdvertiserTrackingEnabledNO();
		} catch(e:Dynamic) {
			trace("setAdvertiserTrackingEnabledNO Exception: " + e);
		}
	}

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
			dispatchEventIfPossible("CLOSED");
			if (completeCB != null) completeCB();

			__reloadRewarded();
		}
		else if (event == "rewardedskipped")
		{
			trace("VIDEO IS SKIPPED");
			dispatchEventIfPossible("CLOSED");
			if (skipCB != null) skipCB();

			__reloadRewarded();
			
		}
		else if (event == "rewarded_displaying")
		{
			trace("VIDEO IS STARTED");
			dispatchEventIfPossible("DISPLAYING");
			if (viewCB != null) viewCB();
		}
		else if (event == "rewarded_click")
		{
			trace("VIDEO IS CLICKED");
			dispatchEventIfPossible("CLICK");
			if (clickCB != null) clickCB();
		}

	}
#elseif android
	private function new() {}

	public function onRewardedCanShow()
	{
		canshow = true;
		trace("REWARDED CAN SHOW");
	}

	public function onRewardedDisplaying()
	{
		trace("REWARDED Displaying");
		dispatchEventIfPossible("DISPLAYING");
		if (viewCB != null) viewCB();
	}

	public function onRewardedClick()
	{
		trace("REWARDED click");
		dispatchEventIfPossible("CLICK");
		if (clickCB != null) clickCB();
	}

	public function onRewardedCompleted()
	{
		trace("REWARDED COMPLETED");
		dispatchEventIfPossible("CLOSED");
		if (completeCB != null) completeCB();
	}
	public function onVideoSkipped()
	{
		trace("VIDEO IS SKIPPED");
		dispatchEventIfPossible("CLOSED");
		if (skipCB != null) skipCB();
	}


#end

	private static function dispatchEventIfPossible(e:String):Void
	{
		if (onRewardedEvent != null)
		{
			onRewardedEvent(e);
		}
		else
		{
			trace('no event handler');
		}
	}
}
