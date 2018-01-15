//
//  SLMusicListView.h
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/15.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLMusicModel : NSObject

/** 歌曲名称 */
@property (nonatomic, copy  ) NSString *music_name;
/** 歌手名称 */
@property (nonatomic, copy  ) NSString *music_artist;
/** 歌曲链接 */
@property (nonatomic, copy  ) NSString *music_link;
/** 唱片封面图片 */
@property (nonatomic, copy  ) NSString *music_picRadio;
/** 会被虚化的背景图片（可不传）*/
@property (nonatomic, copy  ) NSString *music_cover;
/** 是否喜欢 */
@property (nonatomic, assign) NSInteger isLike;

@end

@interface SLMusicListView : UIView

@property (nonatomic, strong) NSArray<SLMusicModel*> *musicList;
@property (nonatomic, strong) SLMusicModel *currentModel;

- (void)showUpList;

@end
