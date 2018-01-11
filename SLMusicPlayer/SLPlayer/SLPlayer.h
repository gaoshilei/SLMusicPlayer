//
//  SLPlayer.h
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SLMusicPlayerStatus) {
    /** 播放器停止 */
    SLMusicPlayerStatusStopped,
    /** 数据流开始传输 */
    SLMusicPlayerStatusOpening,
    /** 数据流缓冲中 */
    SLMusicPlayerStatusBuffering,
    /** 数据流缓冲结束 */
    SLMusicPlayerStatusEnded,
    /** 播放器抛出错误 */
    SLMusicPlayerStatusError,
    /** 数据流播放中 */
    SLMusicPlayerStatusPlaying,
    /** 数据流暂停 */
    SLMusicPlayerStatusPaused,
};

@class SLPlayer;
@protocol SLPlayerDelegate<NSObject>

@optional
/**
 播放状态改变
 */
- (void)slPlayer:(SLPlayer *)player playerStateChanged:(SLMusicPlayerStatus)status;

/**
 获取当前播放时间、总时间（单位为毫秒）以及播放进度
 */
- (void)slPlayer:(SLPlayer *)player currentTime:(NSNumber *)currentTime totalTime:(NSNumber *)totalTime progress:(float)progress;

/**
 获取当前播放时间、总时间（格式化之后的字符串，如23:59:59）以及播放进度
 */
- (void)slPlayer:(SLPlayer *)player formatCurrentTime:(NSString *)currentTimeStr formatTotalTime:(NSString *)totalTimeStr progress:(float)progress;

/**
 获取总时间（毫秒）
 */
- (void)slPlayer:(SLPlayer *)player duration:(double)duration;

/**
 开始播放
 */
- (void)slPlayerIsPlaying:(SLPlayer *)player;

/**
 正在缓存
 */
- (void)slPlayerIsBuffering:(SLPlayer *)player;

@end

@interface SLPlayer : NSObject

/** 播放链接 */
@property (nonatomic, copy  ) NSString *playUrlStr;
/** 播放进度 */
@property (nonatomic, assign) float progress;

@property (nonatomic, weak  ) id<SLPlayerDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isPlaying;

+ (instancetype)shareInstance;
/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 停止
 */
- (void)stop;

/**
 格式化时间
 */
- (NSString *)formatTime:(NSNumber *)timeValue;

@end
