//
//  SLMusicSliderView.h
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>

@class SLMusicSliderView;
@protocol SLMusicSliderDelegate<NSObject>

@optional
/**
 点击播放进度
 */
- (void)slSlider:(SLMusicSliderView *)slider didTappedProgress:(CGFloat)value;

/**
 拖拽开始
 */
- (void)slSlider:(SLMusicSliderView *)slider didTouchBegan:(CGFloat)value;

/**
 拖拽结束
 */
- (void)slSlider:(SLMusicSliderView *)slider didTouchEndded:(CGFloat)value;

/**
 拖拽滑块
 */
- (void)slSlider:(SLMusicSliderView *)slider didDragChangeValue:(CGFloat)value;

@end

@interface SLMusicSliderView : UIView

/** 滑杆背景 */
@property (nonatomic, strong) UIImage *maximumTrackImage;
/** 播放进度背景 */
@property (nonatomic, strong) UIImage *minimumTrackImage;
/** 缓存进度背景 */
@property (nonatomic, strong) UIImage *bufferTrackImage;
/** 滑杆颜色 */
@property (nonatomic, strong) UIColor *maximumTrackTintColor;
/** 播放进度颜色 */
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
/** 缓存进度颜色 */
@property (nonatomic, strong) UIColor *bufferTrackTintColor;
/** 缓存进度 */
@property (nonatomic, assign) float bufferValue;
/** 播放进度 */
@property (nonatomic, assign) float currentValue;
/** 滑杆高度 */
@property (nonatomic, assign) float sliderHeight;

@property (nonatomic, weak  ) id<SLMusicSliderDelegate> delegate;

- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state;
- (void)setThumbImage:(UIImage *)thumbImage forState:(UIControlState)state;

- (void)showBufferIndicator;
- (void)hideBufferIndicator;

@end
