#if __has_include("React/RCTViewManager.h")
#import "React/RCTViewManager.h"
#else
#import "RCTViewManager.h"
#endif
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <ShakaPlayerEmbedded/ShakaPlayerEmbedded.h>
#import "RNShakaPlayerView.h"

@interface RNShakaPlayer : UIView <ShakaPlayerClient>

@property(nonatomic, strong) ShakaPlayer *player;
@property(nonatomic, strong) ShakaPlayerView *playerView;
@property NSTimer *uiTimer;
@property NSTimer *rateTimer;
@property CGFloat currentTime;
@property CGFloat bufferTime;
@property id progressInterval;
@property BOOL repeatPlay;
@property CGFloat lastSeekTime;
@property AVLayerVideoGravity videoGravity;
@property CGFloat playbackRate;
@property CGFloat startRateTime;
@property CGFloat startPlayerTime;
@property BOOL isPlayed;

/** Plays the video. */
- (void)play;

/** Pauses the video. */
- (void)pause;

/** Seek the video. */
- (void)seek:(CGFloat)time;

/** Rerender the video view. */
- (void)rerender;

- (void)setConfig:(NSString*)stringConfig;
- (void)setRepeat:(BOOL)repeat;
- (void)setResizeMode:(NSString*)resizeMode;
- (void)setRate:(CGFloat)rate;

/* av events */
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerError;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerBuffer;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerProgress;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerStart;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerLoad;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerEnd;
@property(nonatomic, copy)RCTBubblingEventBlock onPlayerSeek;

@end
