#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "RNShakaPlayer.h"

@implementation RNShakaPlayer

#pragma mark - RNShakaPlayer allocation

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotated:) name:UIDeviceOrientationDidChangeNotification object:nil];
        self.isPlayed = false;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.playerView != nil) {
        CGRect newFrame = self.frame;
        if (self.superview.frame.size.height > 0) {
            newFrame.size.height = self.superview.frame.size.height;
        } else if (self.superview.superview.frame.size.height > 0) {
            newFrame.size.height = self.superview.superview.frame.size.height;
        }
        self.playerView.frame = newFrame;
        [self.playerView setVideoGravity:self.videoGravity];
        [self.playerView sizeToFit];
    }
}

- (void)updateViews
{
    if (self.player && self.playerView && self.onPlayerProgress) {
        [self.player getUiInfoWithBlock:^(ShakaPlayerUiInfo *info) {
            ShakaBufferedRange *seekable = info.seekRange;
            CGFloat duration = seekable.end - seekable.start;
            CGFloat progress = 0;
            CGFloat bufferedStart = 0;
            CGFloat bufferedEnd = 0;
            // The durations is nan before the asset is loaded; in that situation, the progress should be 0.
            if (!isnan(info.duration)) {
                NSArray<ShakaBufferedRange *> *bufferedRanges = info.bufferedInfo.total;
                progress = info.currentTime;
                if (bufferedRanges.count) {
                    ShakaBufferedRange *buffered = bufferedRanges[0];
                    bufferedStart = buffered.start;
                    bufferedEnd = buffered.end;
                }
            }
            if (self.onPlayerBuffer && self.bufferTime != bufferedEnd && bufferedEnd < duration) {
                self.onPlayerBuffer(@{@"bufferTime": @(bufferedEnd), @"duration": @(duration)});
            }
            self.bufferTime = bufferedEnd;
            if (self.onPlayerProgress && self.currentTime != progress) {
                self.onPlayerProgress(@{@"currentTime": @(progress), @"duration": @(duration), @"seeking": @(info.seeking)});
            }
            if (self.onPlayerEnd && self.currentTime != progress && progress >= duration) {
                self.currentTime = duration;
                self.onPlayerEnd(@{});
                if (self.repeatPlay) {
                self.player.currentTime = 0;
                [self play];
                }
            } else {
                self.currentTime = progress;
            }
        }];
    }
}

- (void)updateWithRate
{
    CGFloat seconds = (CGFloat)([[NSDate date] timeIntervalSince1970]);
    CGFloat diff = seconds - self.startRateTime;
    CGFloat newTime = self.startPlayerTime + (diff * self.playbackRate);
    if (newTime >= self.player.duration) {
        [self pause];
    } else {
        self.player.currentTime = self.startPlayerTime + (diff * self.playbackRate);
    }
}

- (void)removeFromSuperview
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    } @catch(id anException) {
    }
    if (self.uiTimer) {
        [self.uiTimer invalidate];
        self.uiTimer = nil;
    }
    if (self.rateTimer) {
        [self.rateTimer invalidate];
        self.rateTimer = nil;
    }
    [self removePlayerView];
    [super removeFromSuperview];
}

- (void)rotated:(NSNotification *) notification
{
    if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation)) {
        NSLog(@"Landscape");
    }

    if (UIDeviceOrientationIsPortrait(UIDevice.currentDevice.orientation)) {
        NSLog(@"Portrait");
    }

    [self layoutSubviews];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (void)startUITimer:(CGFloat)interval {
    __weak RNShakaPlayer *weakSelf = self;
    self.uiTimer = [NSTimer timerWithTimeInterval:interval
                            repeats:YES
                            block:^(NSTimer * _Nonnull timer) {
                                [weakSelf updateViews];
                            }];
    [[NSRunLoop mainRunLoop] addTimer:self.uiTimer forMode:NSRunLoopCommonModes];
}

- (void)startRateTimer:(CGFloat)interval {
    __weak RNShakaPlayer *weakSelf = self;
    self.rateTimer = [NSTimer timerWithTimeInterval:interval
                            repeats:YES
                            block:^(NSTimer *_Nonnull timer) {
                                [weakSelf updateWithRate];
                            }];
    [[NSRunLoop mainRunLoop] addTimer:self.rateTimer forMode:NSRunLoopCommonModes];
}

#pragma mark - RNShakaPlayer props

- (void)setConfig:(NSString*)stringConfig
{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization
        JSONObjectWithData:[stringConfig dataUsingEncoding:NSUTF8StringEncoding]
        options:0
        error:&error];
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *config = jsonObject;
        
        NSMutableDictionary *configuration = [[NSMutableDictionary alloc] init];
        
        NSString *uri = config[@"uri"];
        NSString *clearKeyLicenseServer = config[@"clearKeyLicenseServer"];
        NSArray *localClearKeys = config[@"localClearKeys"];
        id paused = config[@"paused"];
        self.progressInterval = config[@"progressInterval"];
        self.playbackRate = [config[@"rate"] doubleValue];
        
        int i;
        for (i = 0; i < [localClearKeys count]; i++) {
            NSDictionary *clearKey = [localClearKeys objectAtIndex:i];
            NSString *key = clearKey[@"key"];
            NSString *value = clearKey[@"value"];
            [configuration setValue:value forKey:[NSString stringWithFormat:@"drm.clearKeys.%@", key]];
        }
        if (clearKeyLicenseServer.length) {
            NSMutableDictionary *clearKeyServer = [[NSMutableDictionary alloc] init];
            [clearKeyServer setValue:clearKeyLicenseServer forKey:[NSString stringWithFormat:@"drm.servers.org\\.w3\\.clearkey"]];
            [configuration addEntriesFromDictionary:clearKeyServer];
        }
        
        self.bufferTime = 0;
        self.currentTime = 0;
        [self setRepeat:[config[@"repeat"] boolValue]];
        [self setResizeMode:config[@"resizeMode"]];
        [self setRate:[config[@"rate"] doubleValue]];
        
        if (uri.length) {
            [self setupPlayerView:uri :configuration :[paused boolValue]];
        }
    }
}

- (void)pause
{
    self.isPlayed = false;
    if (self.uiTimer) {
        [self.uiTimer invalidate];
        self.uiTimer = nil;
    }
    if (self.rateTimer) {
        [self.rateTimer invalidate];
        self.rateTimer = nil;
    }
    [self.player pause];
}

- (void)play
{
    self.isPlayed = true;
    if (self.progressInterval) {
        if (self.uiTimer) {
            [self.uiTimer invalidate];
            self.uiTimer = nil;
        }
        [self startUITimer:[self.progressInterval doubleValue]];
    }
    if (self.playbackRate != 1) {
        self.startPlayerTime = self.player.currentTime;
        self.startRateTime =(CGFloat)([[NSDate date] timeIntervalSince1970]);
        if (self.rateTimer) {
            [self.rateTimer invalidate];
            self.rateTimer = nil;
        }
        [self startRateTimer:0.2];
    } else {
        [self.player play];
    }
}

- (void)seek:(CGFloat)time
{
    CGFloat seconds = (CGFloat)([[NSDate date] timeIntervalSince1970]);
    CGFloat diff = seconds - self.lastSeekTime;
    if (diff > 0.2) {
        self.player.currentTime = time;
        self.lastSeekTime = seconds;
        if (self.onPlayerSeek) {
            self.onPlayerSeek(@{@"currentTime": @(self.player.currentTime), @"seekTime": @(time), @"finished": @(YES)});
        }
    }
}

- (void)rerender
{
    [self layoutSubviews];
    self.player.currentTime = self.currentTime;
}

- (void)setRepeat:(BOOL)repeat
{
    self.repeatPlay = repeat;
}

- (void)setResizeMode:(NSString*)resizeMode
{
    if ([resizeMode isEqualToString:@"ScaleNone"]) {
        self.videoGravity = AVLayerVideoGravityResizeAspect;
    } else if ([resizeMode isEqualToString:@"ScaleToFill"]) {
        self.videoGravity = AVLayerVideoGravityResize;
    } else if ([resizeMode isEqualToString:@"ScaleAspectFit"]) {
        self.videoGravity = AVLayerVideoGravityResizeAspect;
    } else if ([resizeMode isEqualToString:@"ScaleAspectFill"]) {
        self.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    [self layoutSubviews];
}

- (void)setRate:(CGFloat)rate
{
    BOOL prevIsPlayed = self.isPlayed;
    if (prevIsPlayed) {
        [self pause];
    }
    self.playbackRate = rate;
    if (prevIsPlayed) {
        [self play];
    }
}

- (void)setPlayerErrorSet:(BOOL)val
{
    // Fabric function
}

- (void)setPlayerBufferSet:(BOOL)val
{
    // Fabric function
}

- (void)setPlayerProgressSet:(BOOL)val
{
    // Fabric function
}

- (void)setPlayerStartSet:(BOOL)val
{
    // Fabric function
}

- (void)setPlayerLoadSet:(BOOL)val
{
    // Fabric function
}

- (void)setPlayerEndSet:(BOOL)val
{
    // Fabric function
}

- (void)setPlayerSeekSet:(BOOL)val
{
    // Fabric function
}

#pragma mark - ShakaPlayer View helpers

-(void)setupPlayerView:assetURI :(NSMutableDictionary*)configuration :(BOOL)paused
{
    if (!self.player) {
        self.player = [[ShakaPlayer alloc] initWithError:nil];
        self.playerView = [[ShakaPlayerView alloc] initWithPlayer:self.player];
    }

    if (configuration) {
        for (NSString *key in configuration) {
            NSObject *value = configuration[key];
            if ([value isKindOfClass:[NSString class]]) {
                NSString *stringValue = (NSString *)value;
                [self.player configure:key withString:stringValue];
            } else if ([value isKindOfClass:[NSNumber class]]) {
                // TODO: Detect if this is a bool, or actually a number.
                NSNumber *numberValue = (NSNumber *)value;
                [self.player configure:key withBool:numberValue.boolValue];
            }
        }
    }

    [self addSubview:self.playerView];
  
    self.lastSeekTime = 0;

    [self.player load:assetURI withStartTime:0 andBlock:^(ShakaPlayerError *error){
        if (self.onPlayerStart) {
            self.onPlayerStart(@{@"uri": assetURI});
        }
        if (error) {
            if (self.onPlayerError) {
                self.onPlayerError(@{@"error": [error message]});
            }
        } else {
            if (self.onPlayerLoad) {
                ShakaStats *playerStats = [self.player getStats];
                NSMutableDictionary *naturalSize = [[NSMutableDictionary alloc] init];
                [naturalSize setValue:@(playerStats.width) forKey:@"width"];
                [naturalSize setValue:@(playerStats.height) forKey:@"height"];
                [naturalSize setValue:(playerStats.width / playerStats.height > 0 ? @"landscape" : @"portrait") forKey:@"orientation"];
                self.onPlayerLoad(@{@"currentPosition": @(self.player.currentTime), @"duration": @(self.player.duration), @"naturalSize": naturalSize});
            }
            if (!paused) {
                [self play];
            } else {
                [self pause];
            }
        }
    }];
}

-(void)removePlayerView
{
    if (self.player) {
        _player.currentTime = 0;
        [self.player unloadWithBlock:^(ShakaPlayerError* error) {
            [self.playerView removeFromSuperview];
            self.player = nil;
            self.playerView = nil;
        }];
    }
}

@end
