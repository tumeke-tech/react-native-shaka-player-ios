// This guard prevent this file to be compiled in the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>
#import "RNShakaPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNShakaPlayerView : RCTViewComponentView

@property(nonatomic, copy)RCTBubblingEventBlock onPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerBuffer;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerProgress;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerStart;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerLoad;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerEnd;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerSeek;

@end

NS_ASSUME_NONNULL_END

#endif /* RCT_NEW_ARCH_ENABLED */
