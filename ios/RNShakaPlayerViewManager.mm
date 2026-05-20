#import "RNShakaPlayerViewManager.h"
#import "RNShakaPlayer.h"
#import "RCTUIManager.h"
#import <React/RCTViewManager.h>

@interface RNShakaPlayerViewManager ()
@end

@implementation RNShakaPlayerViewManager

RCT_EXPORT_MODULE(RNShakaPlayer)

- (UIView*)view
{
  return [[RNShakaPlayer alloc] init];
}

/* player events */
RCT_EXPORT_VIEW_PROPERTY(onPlayerBuffer, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerError, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerProgress, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerStart, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerLoad, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerEnd, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerSeek, RCTBubblingEventBlock);

/* props */
RCT_EXPORT_VIEW_PROPERTY(config, NSString);
RCT_EXPORT_VIEW_PROPERTY(repeat, BOOL);
RCT_EXPORT_VIEW_PROPERTY(resizeMode, NSString);
RCT_EXPORT_VIEW_PROPERTY(rate, CGFloat);
RCT_EXPORT_VIEW_PROPERTY(playerErrorSet, BOOL);
RCT_EXPORT_VIEW_PROPERTY(playerBufferSet, BOOL);
RCT_EXPORT_VIEW_PROPERTY(playerProgressSet, BOOL);
RCT_EXPORT_VIEW_PROPERTY(playerStartSet, BOOL);
RCT_EXPORT_VIEW_PROPERTY(playerLoadSet, BOOL);
RCT_EXPORT_VIEW_PROPERTY(playerEndSet, BOOL);
RCT_EXPORT_VIEW_PROPERTY(playerSeekSet, BOOL);

RCT_EXPORT_METHOD(seek: (nonnull NSNumber *)reactTag: (CGFloat)time) {
#ifdef RCT_NEW_ARCH_ENABLED
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *manager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RNShakaPlayer *view = (RNShakaPlayer *)viewRegistry[reactTag];
#else
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RNShakaPlayer *view = viewRegistry[reactTag];
#endif // RCT_NEW_ARCH_ENABLED
    if (![view isKindOfClass:[RNShakaPlayer class]] || view.playerView == nil) {
      RCTLogError(@"Invalid view returned from registry, expecting RNShakaPlayer, got: %@", view);
    } else {
      [view seek:time];
    }
  }];
}

RCT_EXPORT_METHOD(play:(nonnull NSNumber *)reactTag) {
#ifdef RCT_NEW_ARCH_ENABLED
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *manager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RNShakaPlayer *view = (RNShakaPlayer *)viewRegistry[reactTag];
#else
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RNShakaPlayer *view = viewRegistry[reactTag];
#endif // RCT_NEW_ARCH_ENABLED
    if (![view isKindOfClass:[RNShakaPlayer class]] || view.playerView == nil) {
      RCTLogError(@"Invalid view returned from registry, expecting RNShakaPlayer, got: %@", view);
    } else {
      if (view.player.ended) {
        view.player.currentTime = 0;
        [view play];
      } else {
        [view play];
      }
    }
  }];
}

RCT_EXPORT_METHOD(pause:(nonnull NSNumber *)reactTag) {
#ifdef RCT_NEW_ARCH_ENABLED
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *manager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RNShakaPlayer *view = (RNShakaPlayer *)viewRegistry[reactTag];
#else
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RNShakaPlayer *view = viewRegistry[reactTag];
#endif // RCT_NEW_ARCH_ENABLED
    if (![view isKindOfClass:[RNShakaPlayer class]] || view.playerView == nil) {
      RCTLogError(@"Invalid view returned from registry, expecting RNShakaPlayer, got: %@", view);
    } else {
      [view pause];
    }
  }];
}


RCT_EXPORT_METHOD(stop:(nonnull NSNumber *)reactTag) {
#ifdef RCT_NEW_ARCH_ENABLED
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *manager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RNShakaPlayer *view = (RNShakaPlayer *)viewRegistry[reactTag];
#else
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RNShakaPlayer *view = viewRegistry[reactTag];
#endif // RCT_NEW_ARCH_ENABLED
    if (![view isKindOfClass:[RNShakaPlayer class]] || view.playerView == nil) {
      RCTLogError(@"Invalid view returned from registry, expecting RNShakaPlayer, got: %@", view);
    } else {
      [view pause];
      view.player.currentTime = 0;
    }
  }];
}

RCT_EXPORT_METHOD(rerender:(nonnull NSNumber *)reactTag) {
#ifdef RCT_NEW_ARCH_ENABLED
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *manager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RNShakaPlayer *view = (RNShakaPlayer *)viewRegistry[reactTag];
#else
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RNShakaPlayer *view = viewRegistry[reactTag];
#endif // RCT_NEW_ARCH_ENABLED
    if (![view isKindOfClass:[RNShakaPlayer class]] || view.playerView == nil) {
      RCTLogError(@"Invalid view returned from registry, expecting RNShakaPlayer, got: %@", view);
    } else {
      [view rerender];
    }
  }];
}

@end
