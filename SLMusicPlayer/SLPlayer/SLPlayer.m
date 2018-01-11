//
//  SLPlayer.m
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import "SLPlayer.h"
#import <MobileVLCKit/MobileVLCKit.h>

@interface SLPlayer()<VLCMediaPlayerDelegate> {
    NSString *_totalTime;
}

@property (nonatomic, strong) VLCMediaListPlayer *player;
@property (nonatomic, assign) SLMusicPlayerStatus status;

@end

@implementation SLPlayer

#pragma mark - life cycle
static SLPlayer *sharePlayer = nil;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePlayer = [super allocWithZone:zone];
    });
    return sharePlayer;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePlayer = [super init];
    });
    return sharePlayer;
}

+ (instancetype)shareInstance {
    return [[self alloc] init];
}

#pragma mark - lazy load
- (VLCMediaListPlayer *)player {
    if (!_player) {
        _player = [[VLCMediaListPlayer alloc] init];
        _player.repeatMode = VLCDoNotRepeat;
        _player.mediaPlayer.delegate = self;
    }
    return _player;
}

#pragma mark - public method

- (void)setPlayUrlStr:(NSString *)playUrlStr {
    _playUrlStr = playUrlStr;
    VLCMedia *media = [VLCMedia mediaWithURL:[NSURL URLWithString:playUrlStr]];
    VLCMediaList *mediaList = [[VLCMediaList alloc] initWithArray:@[media]];
    self.player.mediaList = mediaList;
}

- (void)play {
    if (self.isPlaying) {
        return;
    }
    NSLog(@"%s",__func__);
    _totalTime = nil;
    [self.player play];
}

- (void)pause {
    NSLog(@"%s",__func__);
    [self.player pause];
}

- (void)stop {
    NSLog(@"%s",__func__);
    [self.player stop];
}

- (void)setProgress:(float)progress {
    _progress = progress;
    self.player.mediaPlayer.position = progress;
}

- (BOOL)isPlaying {
    return self.status == SLMusicPlayerStatusPlaying;
}

#pragma mark - VLCMediaPlayerDelegate

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    switch (self.player.mediaPlayer.state) {
        case VLCMediaPlayerStateStopped:
            self.status = SLMusicPlayerStatusStopped;
            NSLog(@"播放器停止");
            break;
        case VLCMediaPlayerStateEnded:
            self.status = SLMusicPlayerStatusEnded;
            NSLog(@"数据流缓冲结束");
            break;
        case VLCMediaPlayerStateOpening:
            self.status = SLMusicPlayerStatusOpening;
            NSLog(@"数据流开始传输");
            break;
        case VLCMediaPlayerStateBuffering: {
            self.status = SLMusicPlayerStatusBuffering;
            if ([self.delegate respondsToSelector:@selector(slPlayerIsBuffering:)]) {
                [self.delegate slPlayerIsBuffering:self];
            }
            NSLog(@"数据流缓冲中");
        }
            break;
        case VLCMediaPlayerStatePaused:
            self.status = SLMusicPlayerStatusPaused;
            NSLog(@"数据流暂停");
            break;
        case VLCMediaPlayerStateError:
            self.status = SLMusicPlayerStatusError;
            NSLog(@"播放器抛出错误");
            break;
        case VLCMediaPlayerStatePlaying:
            self.status = SLMusicPlayerStatusPlaying;
            NSLog(@"数据流播放中");
            break;
    }
    if (self.player.mediaPlayer.isPlaying) {
        self.status = SLMusicPlayerStatusPlaying;
        NSLog(@"==播放中==");
        if ([self.delegate respondsToSelector:@selector(slPlayerIsPlaying:)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate slPlayerIsPlaying:self];
            });
        }
    }
    if ([self.delegate respondsToSelector:@selector(slPlayer:playerStateChanged:)]) {
        [self.delegate slPlayer:self playerStateChanged:self.status];
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    VLCMediaPlayer *mediaPlayer = aNotification.object;
    VLCTime *time = mediaPlayer.time;
    NSNumber *totalTimeValue = mediaPlayer.media.length.value;
    float progress = mediaPlayer.position;
    if ([self.delegate respondsToSelector:@selector(slPlayer:currentTime:totalTime:progress:)]) {
        [self.delegate slPlayer:self currentTime:time.value totalTime:totalTimeValue progress:progress];
    }
    if ([self.delegate respondsToSelector:@selector(slPlayer:formatCurrentTime:formatTotalTime:progress:)]) {
        NSString *currentTimeStr = [self formatTime:time.value];
        NSString *totalTimeStr = [self formatTime:totalTimeValue];
        [self.delegate slPlayer:self formatCurrentTime:currentTimeStr formatTotalTime:totalTimeStr progress:progress];
    }
    if (!_totalTime) {
        _totalTime = [NSString stringWithFormat:@"%@",totalTimeValue];
        if ([self.delegate respondsToSelector:@selector(slPlayer:duration:)]) {
            [self.delegate slPlayer:self duration:totalTimeValue.doubleValue];
        }
    }
}

- (NSString *)formatTime:(NSNumber *)timeValue {
    NSInteger time = timeValue.integerValue / 1000;
    if (timeValue.integerValue%1000>0) {
        time++;
    }
    if (time < 3600) {
        NSInteger minutes = time / 60;
        NSInteger seconds = time % 60;
        return [NSString stringWithFormat:@"%02zd:%02zd",minutes,seconds];
    }else {
        NSInteger hours = time / 3600;
        NSInteger minutes = (time % 3600) / 60;
        NSInteger seconds = (time % 3600) % 60;
        return [NSString stringWithFormat:@"%02zd:%02zd:%02zd",hours,minutes,seconds];
    }
}


@end
