//
//  SLMusicPlayerController.h
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLMusicListView.h"

@protocol SLMusicPlayerDelegate<NSObject>

/** 下载歌曲 */
- (void)slMusicPlayerClickDownloadSong:(SLMusicModel *)model;
/** 点击更多 */
- (void)slMusicPlayerClickMore:(SLMusicModel *)model;
/** 点击喜欢 */
- (void)slMusicPlayerClickLike:(SLMusicModel *)model;

@end

@interface SLMusicPlayerController : UIViewController

@property (nonatomic, copy) NSArray <SLMusicModel*> *musicList;
@property (nonatomic, weak) id<SLMusicPlayerDelegate> delegate;

+ (instancetype)shareInstance;

@end
