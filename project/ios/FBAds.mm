#include <FacebookAdsEx.h>
#include "RewardedVideoViewController.m"

namespace facebookadsex {
	
	static RewardedVideoViewController *rewardedVideoAd;
	static NSString *rewardedID;

	void init(const char *__RewardedID, bool testingAds) {
		
		rewardedID = [NSString stringWithUTF8String:__RewardedID];

		if (testingAds) {
			NSString *testDeviceKey = [FBAdSettings testDeviceHash];
			[FBAdSettings addTestDevice:testDeviceKey];

			[FBAdSettings setAdvertiserTrackingEnabled:YES];
		}

		rewardedVideoAd = [RewardedVideoViewController alloc];
		[rewardedVideoAd loadAd:rewardedID];
	}

	void reloadRewarded(){
		[rewardedVideoAd reloadAd:rewardedID];
	}

	void showRewarded(){
		[rewardedVideoAd showAd];
	}

}
