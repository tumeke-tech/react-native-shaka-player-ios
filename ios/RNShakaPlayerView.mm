// This guard prevent the code from being compiled in the old architecture
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNShakaPlayerView.h"
#import "RNShakaPlayer.h"

#import <react/renderer/components/RNShakaPlayerSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNShakaPlayerSpec/EventEmitters.h>
#import <react/renderer/components/RNShakaPlayerSpec/Props.h>
#import <react/renderer/components/RNShakaPlayerSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface RNShakaPlayerView () <RCTRNShakaPlayerViewProtocol>

@end

@implementation RNShakaPlayerView {
    RNShakaPlayer * view;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<RNShakaPlayerComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const RNShakaPlayerProps>();
        _props = defaultProps;
        
        view = [[RNShakaPlayer alloc] init];
        
        self.contentView = view;
    }
    
    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<RNShakaPlayerProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<RNShakaPlayerProps const>(props);
    __weak RNShakaPlayerView *weakSelf = self;
    
    if (oldViewProps.config != newViewProps.config) {
        NSString* config = [[NSString alloc] initWithUTF8String: newViewProps.config.c_str()];
        [view setConfig:config];
    }
    if (oldViewProps.repeat != newViewProps.repeat) {
        [view setRepeat:newViewProps.repeat];
    }
    if (oldViewProps.rate != newViewProps.rate) {
        [view setRate:newViewProps.rate];
    }
    if (oldViewProps.resizeMode != newViewProps.resizeMode) {
        NSString* resizeMode = [[NSString alloc] initWithUTF8String: newViewProps.resizeMode.c_str()];
        [view setResizeMode:resizeMode];
    }
    if (newViewProps.playerErrorSet && !view.onPlayerError) {
        view.onPlayerError = ^(NSDictionary* body) {
            [weakSelf onPlayerError:body];
        };
    }
    if (newViewProps.playerBufferSet && !view.onPlayerBuffer) {
        view.onPlayerBuffer = ^(NSDictionary* body) {
            [weakSelf onPlayerBuffer:body];
        };
    }
    if (newViewProps.playerProgressSet && !view.onPlayerProgress) {
        view.onPlayerProgress = ^(NSDictionary* body) {
            [weakSelf onPlayerProgress:body];
        };
    }
    if (newViewProps.playerStartSet && !view.onPlayerStart) {
        view.onPlayerStart = ^(NSDictionary* body) {
            [weakSelf onPlayerStart:body];
        };
    }
    if (newViewProps.playerLoadSet && !view.onPlayerLoad) {
        view.onPlayerLoad = ^(NSDictionary* body) {
            [weakSelf onPlayerLoad:body];
        };
    }
    if (newViewProps.playerEndSet && !view.onPlayerEnd) {
        view.onPlayerEnd = ^(NSDictionary* body) {
            [weakSelf onPlayerEnd:body];
        };
    }
    if (newViewProps.playerSeekSet && !view.onPlayerSeek) {
        view.onPlayerSeek = ^(NSDictionary* body) {
            [weakSelf onPlayerSeek:body];
        };
    }
    
    [super updateProps:props oldProps:oldProps];
}

- (void)removeFromSuperview
{
    if (view) {
        [view removeFromSuperview];
    }
    [super removeFromSuperview];
}

# pragma mark - Life cycle

- (void)prepareForRecycle {
    [super prepareForRecycle];
    
    static const auto defaultProps = std::make_shared<const RNShakaPlayerProps>();
    _props = defaultProps;
    
    view = [[RNShakaPlayer alloc] init];
    
    self.contentView = view;
}

#pragma mark - Bubbling events

- (void)onPlayerError:(NSDictionary *)body
{
    if (!self->_eventEmitter) {
        return;
    }
    NSString *error = [body valueForKey:@"error"];
    std::dynamic_pointer_cast<const RNShakaPlayerEventEmitter>(self->_eventEmitter)->onPlayerError(RNShakaPlayerEventEmitter::OnPlayerError{
        .error = static_cast<std::string>(std::string([error UTF8String])),
    });
}

- (void)onPlayerBuffer:(NSDictionary *)body
{
    if (!self->_eventEmitter) {
        return;
    }
    NSNumber *bufferTime = [body valueForKey:@"bufferTime"];
    NSNumber *duration = [body valueForKey:@"duration"];
    std::dynamic_pointer_cast<const RNShakaPlayerEventEmitter>(self->_eventEmitter)->onPlayerBuffer(RNShakaPlayerEventEmitter::OnPlayerBuffer{
        .bufferTime = static_cast<Float>([bufferTime floatValue]),
        .duration = static_cast<Float>([duration floatValue]),
    });
}

- (void)onPlayerProgress:(NSDictionary *)body
{
    if (!self->_eventEmitter) {
        return;
    }
    NSNumber *currentTime = [body valueForKey:@"currentTime"];
    NSNumber *duration = [body valueForKey:@"duration"];
    id seeking = [body valueForKey:@"seeking"];
    std::dynamic_pointer_cast<const RNShakaPlayerEventEmitter>(self->_eventEmitter)->onPlayerProgress(RNShakaPlayerEventEmitter::OnPlayerProgress{
        .currentTime = static_cast<Float>([currentTime floatValue]),
        .duration = static_cast<Float>([duration floatValue]),
        .seeking = static_cast<BOOL>([seeking boolValue]),
    });
}

- (void)onPlayerStart:(NSDictionary *)body
{
    if (!self->_eventEmitter) {
        return;
    }
    NSString *uri = [body valueForKey:@"uri"];
    std::dynamic_pointer_cast<const RNShakaPlayerEventEmitter>(self->_eventEmitter)->onPlayerStart(RNShakaPlayerEventEmitter::OnPlayerStart{
        .uri = static_cast<std::string>(std::string([uri UTF8String])),
    });
}

- (void)onPlayerLoad:(NSDictionary *)body
{
    if (!self->_eventEmitter) {
        return;
    }
    NSNumber *currentPosition = [body valueForKey:@"currentPosition"];
    NSNumber *duration = [body valueForKey:@"duration"];
    NSDictionary *naturalSize = [body valueForKey:@"naturalSize"];
    NSNumber *width = [naturalSize valueForKey:@"width"];
    NSNumber *height = [naturalSize valueForKey:@"height"];
    NSString *orientation = [naturalSize valueForKey:@"orientation"];
    std::dynamic_pointer_cast<const RNShakaPlayerEventEmitter>(self->_eventEmitter)->onPlayerLoad(RNShakaPlayerEventEmitter::OnPlayerLoad{
        .currentPosition = static_cast<Float>([currentPosition floatValue]),
        .duration = static_cast<Float>([duration floatValue]),
        .naturalSize = {
            .width = static_cast<Float>([width floatValue]),
            .height = static_cast<Float>([height floatValue]),
            .orientation = static_cast<std::string>(std::string([orientation UTF8String])),
        },
    });
}

- (void)onPlayerEnd:(NSDictionary *)body
{
    if (!self->_eventEmitter) {
        return;
    }
    std::dynamic_pointer_cast<const RNShakaPlayerEventEmitter>(self->_eventEmitter)->onPlayerEnd(RNShakaPlayerEventEmitter::OnPlayerEnd{});
}

- (void)onPlayerSeek:(NSDictionary *)body
{
    if (!self->_eventEmitter) {
        return;
    }
    NSNumber *currentTime = [body valueForKey:@"currentTime"];
    NSNumber *seekTime = [body valueForKey:@"seekTime"];
    std::dynamic_pointer_cast<const RNShakaPlayerEventEmitter>(self->_eventEmitter)->onPlayerSeek(RNShakaPlayerEventEmitter::OnPlayerSeek{
        .currentTime = static_cast<Float>([currentTime floatValue]),
        .seekTime = static_cast<Float>([seekTime floatValue]),
    });
}


#pragma mark - Native commands

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
    RCTRNShakaPlayerHandleCommand(self, commandName, args);
}

- (void)play
{
    if (view.player.ended) {
        view.player.currentTime = 0;
        [view play];
    } else {
        [view play];
    }
}

- (void)pause
{
    [view pause];
}

- (void)stop
{
    [view pause];
    view.player.currentTime = 0;

}

- (void)seek:(float)time
{
    [view seek:CGFloat(time)];
}

- (void)rerender
{
    [view rerender];
}

Class<RCTComponentViewProtocol> RNShakaPlayerCls(void)
{
    return RNShakaPlayerView.class;
}

@end
#endif
