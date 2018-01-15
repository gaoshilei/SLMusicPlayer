//
//  SLMusicControlView.h
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SLPlayerLoopStyle) {
    /*
     循环播放
     **/
    SLPlayerLoopStyleLooping        = 0,
    /*
     单曲循环
     **/
    SLPlayerLoopStyleSingleCycle    = 1,
    /*
     随机播放
     **/
    SLPlayerLoopStyleRandom         = 2,
};

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

- (void)musicControl:(SLMusicControlView *)control didSliderTapped:(CGFloat)value;
- (void)musicControl:(SLMusicControlView *)control didSliderTouchBegan:(CGFloat)value;
- (void)musicControl:(SLMusicControlView *)control didSliderTouchChanged:(CGFloat)value;
- (void)musicControl:(SLMusicControlView *)control didSliderTouchEnded:(CGFloat)value;

@end

@interface SLMusicControlView : UIView

@property (nonatomic, copy  ) NSString *currentTime;
@property (nonatomic, copy  ) NSString *totalTime;
@property (nonatomic, assign) CGFloat  currentValue;
@property (nonatomic, weak  ) id<SLMusicControlDelegate> delegate;

- (void)startPlay;
- (void)stopPlay;

- (void)showAndHideBufferIndicator;
- (void)setLoopStyle:(SLPlayerLoopStyle)loopStyle;

@end
