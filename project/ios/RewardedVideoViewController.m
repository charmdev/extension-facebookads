#import "RewardedVideoViewController.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface RewardedVideoViewController () <FBRewardedVideoAdDelegate>

@property (nonatomic, strong) FBRewardedVideoAd *rewardedVideoAd;

@property (assign) BOOL giveReward;
@property (assign) NSString *adId;

@end

@implementation RewardedVideoViewController

extern "C" void sendAdsEvent(char* event);

- (IBAction)loadAd:(NSString *)rewardedid
{
    NSLog(@"Rewarded video LoadAd id %@", rewardedid);

    self.adId = rewardedid;

    self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:rewardedid];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAd];
}

- (void)reloadAd
{
    NSLog(@"Rewarded video reLoadAd id %@", self.adId);

    self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:self.adId];
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
    sendAdsEvent("rewardedcanshow");

    self.giveReward = false;

    NSLog(@"Rewarded video ad was loaded. Can present now.");
}



- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    if (self.giveReward)
    {
       sendAdsEvent("rewardedcompleted");
    }
    else
    {
        sendAdsEvent("rewardedskip");
    }

    NSLog(@"Rewarded video closed.");
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd
{
    self.giveReward = true;
    NSLog(@"Rewarded video was completed successfully.");
}





- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    self.giveReward = false;

    NSLog(@"Rewarded video failed to load with error: %@", error.description);
}

- (void)rewardedVideoAdWillClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Rewarded video will close.");
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Rewarded video impression is being captured.");
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Rewarded video was clicked.");
}

@end