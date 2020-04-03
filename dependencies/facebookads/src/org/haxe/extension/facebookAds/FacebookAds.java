package org.haxe.extension.facebookAds;

import android.util.Log;
import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;
import com.facebook.ads.*;

import android.opengl.GLSurfaceView;

public class FacebookAds extends Extension
{
	protected static FacebookAds instance = null;
	
	protected static FacebookAds getInstance() {
		if (instance == null) instance = new FacebookAds();
		return instance;
	}

	protected FacebookAds () { }

	protected static HaxeObject _callback = null;
	protected static String rewardedID = null;
	protected static final String TAG = "FacebookAds";
	protected static boolean rewardedLoadedFlag = false;
	protected static RewardedVideoAd rewardedVideoAd;
	protected static boolean giveReward = false;

	public static void init(boolean testingAds, HaxeObject callback, String rewardedVideoID) {
		
		_callback = callback;
		if (testingAds) useTestingAds();
		
		FacebookAds.rewardedID = rewardedVideoID;

		Extension.mainActivity.runOnUiThread(new Runnable() {
			public void run() {

				rewardedVideoAd = new RewardedVideoAd(Extension.mainActivity.getApplicationContext(), FacebookAds.rewardedID);
				rewardedVideoAd.setAdListener(new RewardedVideoAdExtendedListener() {
					@Override
					public void onError(Ad ad, AdError error) {
						Log.e(TAG, "Rewarded video ad failed to load: " + error.getErrorMessage());
						giveReward = false;
					}

					@Override
					public void onAdLoaded(Ad ad) {
						Log.d(TAG, "Rewarded video ad is loaded and ready to be displayed!");
						rewardedLoadedFlag = true;
						giveReward = false;

						if (Extension.mainView == null) return;
						GLSurfaceView view = (GLSurfaceView) Extension.mainView;
						view.queueEvent(new Runnable() {
							public void run() {

								_callback.call("onRewardedCanShow", new Object[] {});

						}});
					}

					@Override
					public void onAdClicked(Ad ad) {
						Log.d(TAG, "Rewarded video ad clicked!");
					}

					@Override
					public void onLoggingImpression(Ad ad) {
						Log.d(TAG, "Rewarded video ad impression logged!");
					}

					@Override
					public void onRewardedVideoCompleted() {
						Log.d(TAG, "Rewarded video completed!");
						
						giveReward = true;
					}

					@Override
					public void onRewardedVideoClosed() {
						// The Rewarded Video ad was closed - this can occur during the video
						// by closing the app, or closing the end card.
						Log.d(TAG, "Rewarded video ad closed!");

						if (giveReward)
						{
							if (Extension.mainView == null) return;
							GLSurfaceView view = (GLSurfaceView) Extension.mainView;
							view.queueEvent(new Runnable() {
								public void run() {
									
									_callback.call("onRewardedCompleted", new Object[] {});

							}});

							Log.d(TAG, "Rewarded video CB onRewardedCompleted!");
						}
					}

					@Override
					public void onRewardedVideoActivityDestroyed() {

						if (!giveReward)
						{
							if (Extension.mainView == null) return;
							GLSurfaceView view = (GLSurfaceView) Extension.mainView;
							view.queueEvent(new Runnable() {
								public void run() {

									_callback.call("onVideoSkipped", new Object[] {});

							}});
						}
						else
						{
							giveReward = false;
						}

						rewardedVideoAd.loadAd();
						
						Log.d(TAG, "Rewarded video ad Destroyed!");
					}
					
				});
				rewardedVideoAd.loadAd();

			}
		});
	}
	
	public static void showRewarded() {
		if (!rewardedLoadedFlag) return;
		Extension.mainActivity.runOnUiThread(new Runnable() {
			public void run() {
				if (rewardedLoadedFlag) {
					rewardedLoadedFlag = false;
					rewardedVideoAd.show();
				}
			}
		});
	}

	private static void useTestingAds() {
		String id = Extension.mainActivity.getApplicationContext().getSharedPreferences("FBAdPrefs", 0).getString("deviceIdHash", null);
		Log.d(TAG,"Enabling Testing Ads for hashID: "+id);
		AdSettings.addTestDevice(id);
	}

}
