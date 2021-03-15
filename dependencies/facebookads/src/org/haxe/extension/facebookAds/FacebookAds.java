package org.haxe.extension.facebookAds;

import android.util.Log;
import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;
import com.facebook.ads.*;

import android.opengl.GLSurfaceView;

public class FacebookAds extends Extension
{
	protected FacebookAds () { }

	protected static HaxeObject _callback = null;
	protected static String rewardedID = null;
	protected static final String TAG = "FacebookAds";
	protected static boolean rewardedLoadedFlag = false;
	protected static RewardedVideoAd rewardedVideoAd;
	protected static RewardedVideoAdExtendedListener rewardedVideoAdListener;
	protected static boolean giveReward = false;
	protected static boolean rewardSended = false;

	public static void init(boolean testingAds, HaxeObject callback, String rewardedVideoID) {
		
		_callback = callback;
		if (testingAds) useTestingAds();
		
		FacebookAds.rewardedID = rewardedVideoID;

		Extension.mainActivity.runOnUiThread(new Runnable() {
			public void run() {

				rewardedVideoAd = new RewardedVideoAd(Extension.mainActivity.getApplicationContext(), FacebookAds.rewardedID);

				rewardedVideoAdListener = new RewardedVideoAdExtendedListener() {
					@Override
					public void onError(Ad ad, AdError error) {
						Log.e(TAG, "Rewarded video ad failed to load: " + error.getErrorMessage());
						giveReward = false;
						rewardSended = false;
					}

					@Override
					public void onAdLoaded(Ad ad) {
						Log.d(TAG, "Rewarded video ad is loaded and ready to be displayed!");
						rewardedLoadedFlag = true;
						giveReward = false;
						rewardSended = false;

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
						rewardSended = false;
					}

					@Override
					public void onRewardedVideoClosed() {
						Log.d(TAG, "Rewarded video ad closed!");

						if (giveReward && !rewardSended)
						{
							if (Extension.mainView == null) return;
							rewardSended = true;
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
						
						if (giveReward && !rewardSended)
						{
							if (Extension.mainView == null) return;
							GLSurfaceView view = (GLSurfaceView) Extension.mainView;
							view.queueEvent(new Runnable() {
								public void run() {
									_callback.call("onRewardedCompleted", new Object[] {});
							}});

							Log.d(TAG, "Rewarded video ad Destroyed! giveReward");
						}
						else if (!giveReward && !rewardSended)
						{
							if (Extension.mainView == null) return;
							GLSurfaceView view = (GLSurfaceView) Extension.mainView;
							view.queueEvent(new Runnable() {
								public void run() {
									_callback.call("onVideoSkipped", new Object[] {});
							}});

							Log.d(TAG, "Rewarded video ad Destroyed! !giveReward");
						}

						giveReward = false;
						rewardSended = false;

						rewardedVideoAd.loadAd(rewardedVideoAd.buildLoadAdConfig()
						.withAdListener(rewardedVideoAdListener)
						.build() );

						Log.d(TAG, "Rewarded video ad Destroyed! load ad" );
					}
				};

				rewardedVideoAd.loadAd(rewardedVideoAd.buildLoadAdConfig()
						.withAdListener(rewardedVideoAdListener)
						.build() );
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
