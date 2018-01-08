//
//  SLMusicPlayerController.h
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLMusicModel : NSObject

/** 歌曲名称 */
@property (nonatomic, copy  ) NSString *songName;
/** 歌手名称 */
@property (nonatomic, copy  ) NSString *singerName;
/** 歌曲链接 */
@property (nonatomic, copy  ) NSString *songLink;
/** 唱片封面图片 */
@property (nonatomic, copy  ) NSString *songDiscPic;
/** 会被虚化的背景图片（可不传）*/
@property (nonatomic, copy  ) NSString *songBgPic;
/** 是否喜欢 */
@property (nonatomic, assign) BOOL isLike;

@end

typedef NS_ENUM(NSInteger, SLPlayerPlayStyle) {
    /*
     循环播放
     **/
    SLPlayerPlayStyleLoop           = 0,
    /*
     单曲循环
     **/
    SLPlayerPlayStyleSingleCycle    = 1,
    /*
     随机播放
     **/
    SLPlayerPlayStyleRandom         = 2,
};

@interface SLMusicPlayerController : UIViewController

@property (nonatomic, strong) SLMusicModel *songModel;

+ (instancetype)shareInstance;

@end
