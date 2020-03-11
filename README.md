## extension-facebookads

import extension.facebookads.FacebookAds;

//FacebookAds.enableTestingAds();

#if ios

FacebookAds.init("PlacementID");

#elseif android

FacebookAds.init("PlacementID");

#end

  FacebookAds.showRewarded(function(){
      trace("CB VIDEO SUCCESSFUL");
    },
    function() {
      trace("CB VIDEO SKIPPED");
    }
  );

## Main Features

  * Rewarded Video Support
