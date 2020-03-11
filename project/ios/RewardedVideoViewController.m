#import "RewardedVideoViewController.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface RewardedVideoViewController () <FBRewardedVideoAdDelegate>
@property (nonatomic, strong) FBRewardedVideoAd *rewardedVideoAd;
@end

@implementation RewardedVideoViewController

extern "C" void sendAdsEvent(char* event);

- (IBAction)loadAd:(NSString *)rewardedid
{
    NSLog(@"Rewarded video LoadAd id %@", rewardedid);

    self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:rewardedid];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAd];
}

- (IBAction)showAd
{
    if (!self.rewardedVideoAd || !self.rewardedVideoAd.isAdValid)
    {
       NSLog(@"Rewarded video Ad not loaded. Click load to request an ad");
    } else {
        
        UIViewController *root_ = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [self.rewardedVideoAd showAdFromRootViewController:root_];

        NSLog(@"Rewarded video ShowAd");
    }
}

#pragma mark - FBRewardedVideoAdDelegate implementation

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Rewarded video ad was loaded. Can present now.");
}

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    NSLog(@"Rewarded video failed to load with error: %@", error.description);
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Rewarded video was clicked.");
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    sendAdsEvent("rewardedcompleted");

    NSLog(@"Rewarded video closed.");
}

- (void)rewardedVideoAdWillClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Rewarded video will close.");
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Rewarded video impression is being captured.");
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Rewarded video was completed successfully.");
}


@end