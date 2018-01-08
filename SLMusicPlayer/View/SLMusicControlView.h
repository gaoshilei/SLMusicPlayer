//
//  SLMusicControlView.h
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLMusicControlView;
@protocol SLMusicControlDelegate<NSObject>

@optional
- (void)musicControl:(SLMusicControlView *)control didClickLike:(UIButton *)likeBtn;
- (void)musicControl:(SLMusicControlView *)control didClickDownload:(UIButton *)downloadBtn;
- (void)musicControl:(SLMusicControlView *)control didClickMore:(UIButton *)moreBtn;
- (void)musicControl:(SLMusicControlView *)control didClickLoop:(UIButton *)loopBtn;
- (void)musicControl:(SLMusicControlView *)control didClickPrevious:(UIButton *)prevBtn;
- (void)musicControl:(SLMusicControlView *)control didClickPlay:(UIButton *)playBtn;
- (void)musicControl:(SLMusicControlView *)control didClickNext:(UIButton *)nextBtn;
- (void)musicControl:(SLMusicControlView *)control didClickList:(UIButton *)listBtn;

@end

@interface SLMusicControlView : UIView

@property (nonatomic, weak) id<SLMusicControlDelegate> delegate;

@end
