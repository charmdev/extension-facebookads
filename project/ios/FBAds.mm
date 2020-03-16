#include <FacebookAdsEx.h>
#include "RewardedVideoViewController.m"

namespace facebookadsex {
	
	static RewardedVideoViewController *rewardedVideoAd;

	void init(const char *__RewardedID, bool testingAds) {
		
		NSString *rewardedID = [NSString stringWithUTF8String:__RewardedID];

		if (testingAds) {
			NSString *testDeviceKey = [FBAdSettings testDeviceHash];
			[FBAdSettings addTestDevice:testDeviceKey];
		}

		rewardedVideoAd = [RewardedVideoViewController alloc];
		[rewardedVideoAd loadAd:rewardedID];
	}

	void reloadRewarded(){
		[rewardedVideoAd reloadAd];
	}

	void showRewarded(){
		[rewardedVideoAd showAd];
	}

}
