//
//  SLMusicSliderView.m
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#define kSliderBtnWH    16.f
#define kProgressMargin 2.f
#define kProgressH      3.f

#import "SLMusicSliderView.h"

@interface SLSliderButton : UIButton

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

- (void)showActivityAnim;
- (void)hideActivityAnim;

@end

@implementation SLSliderButton

- (instancetype)init {
    if (self = [super init]) {
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicatorView.hidesWhenStopped = NO;
        self.indicatorView.userInteractionEnabled = NO;
        self.indicatorView.frame = CGRectMake(0, 0, 20, 20);
        self.indicatorView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        
        [self addSubview:self.indicatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    self.indicatorView.transform = CGAffineTransformMakeScale(0.6, 0.6);
}

- (void)showActivityAnim {
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
}

- (void)hideActivityAnim {
    self.indicatorView.hidden = YES;
    [self.indicatorView stopAnimating];
}

//扩大点击范围
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -20.f, -20.f);
    return CGRectContainsPoint(bounds, point);
}

@end

@interface SLMusicSliderView()

/** 滑块 */
@property (nonatomic, strong) UIImageView *progressView;
/** 已经播放的进度 */
@property (nonatomic, strong) UIImageView *progressPassedView;
/** 缓存的进度 */
@property (nonatomic, strong) UIImageView *progressBufferView;
/** 滑块 */
@property (nonatomic, strong) SLSliderButton *sliderButton;

@end

@implementation SLMusicSliderView

- (instancetype)init {
    if (self = [super init]) {
        [self p_initSubviews];
    }
    return self;
}

- (void)p_initSubviews {
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.progressView];
    [self addSubview:self.progressPassedView];
    [self addSubview:self.progressBufferView];
    [self addSubview:self.sliderButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_sliderTapped:)];
    [self addGestureRecognizer:tap];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.equalTo(self);
    }];
    [self.progressPassedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self);
    }];
    [self.progressBufferView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self);
    }];
    [self.sliderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kSliderBtnWH);
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(-kSliderBtnWH/2);
    }];
    [self.sliderButton hideActivityAnim];
}

#pragma mark - lazy load

- (UIImageView *)progressView {
    if (!_progressView) {
        _progressView = [[UIImageView alloc] init];
        _progressView.backgroundColor = [UIColor grayColor];
        _progressView.clipsToBounds = YES;
    }
    return _progressView;
}

- (UIImageView *)progressPassedView {
    if (!_progressPassedView) {
        _progressPassedView = [[UIImageView alloc] init];
        _progressPassedView.backgroundColor = [UIColor whiteColor];
        _progressPassedView.clipsToBounds = YES;
    }
    return _progressPassedView;
}

- (UIImageView *)progressBufferView {
    if (!_progressBufferView) {
        _progressBufferView = [[UIImageView alloc] init];
        _progressBufferView.backgroundColor = [UIColor whiteColor];
        _progressBufferView.clipsToBounds = YES;
    }
    return _progressBufferView;
}


- (SLSliderButton *)sliderButton {
    if (!_sliderButton) {
        _sliderButton = [[SLSliderButton alloc] init];
        [_sliderButton addTarget:self action:@selector(sliderBtnTouchBegin:) forControlEvents:UIControlEventTouchDown];
        [_sliderButton addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchCancel];
        [_sliderButton addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
        [_sliderButton addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
        [_sliderButton addTarget:self action:@selector(sliderBtnDragMoving:event:) forControlEvents:UIControlEventTouchDragInside];
    }
    return _sliderButton;
}

#pragma mark - User Interaction

- (void)p_sliderTapped:(UITapGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:self];
    CGFloat positionValue = location.x / self.frame.size.width;
    if ([self.delegate respondsToSelector:@selector(slSlider:didTappedProgress:)]) {
        [self.delegate slSlider:self didTappedProgress:positionValue];
    }
}

- (void)sliderBtnTouchBegin:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(slSlider:didTouchBegan:)]) {
        [self.delegate slSlider:self didTouchBegan:self.currentValue];
    }
}

- (void)sliderBtnTouchEnded:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(slSlider:didTouchEndded:)]) {
        [self.delegate slSlider:self didTouchEndded:self.currentValue];
    }
}

- (void)sliderBtnDragMoving:(UIButton *)btn event:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    CGFloat value = location.x / self.frame.size.width;
    value = value>1.0?1.0:value<0?0:value;
    if ([self.delegate respondsToSelector:@selector(slSlider:didDragChangeValue:)]) {
        [self.delegate slSlider:self didDragChangeValue:value];
    }
}

#pragma mark - public method
- (void)showBufferIndicator {
    [self.sliderButton showActivityAnim];
}

- (void)hideBufferIndicator {
    [self.sliderButton hideActivityAnim];
}

- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage {
    _maximumTrackImage = maximumTrackImage;
    self.progressView.image = maximumTrackImage;
    self.maximumTrackTintColor = [UIColor clearColor];
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage {
    _minimumTrackImage = minimumTrackImage;
    self.progressPassedView.image = minimumTrackImage;
    self.minimumTrackTintColor = [UIColor clearColor];
}

- (void)setBufferTrackImage:(UIImage *)bufferTrackImage {
    _bufferTrackImage = bufferTrackImage;
    self.progressBufferView.image = bufferTrackImage;
    self.bufferTrackTintColor = [UIColor clearColor];
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _maximumTrackTintColor = maximumTrackTintColor;
    self.progressView.backgroundColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    _minimumTrackTintColor = minimumTrackTintColor;
    self.progressPassedView.backgroundColor = minimumTrackTintColor;
}

- (void)setBufferTrackTintColor:(UIColor *)bufferTrackTintColor {
    _bufferTrackTintColor = bufferTrackTintColor;
    self.progressBufferView.backgroundColor = bufferTrackTintColor;
}

- (void)setSliderHeight:(float)sliderHeight {
    _sliderHeight = sliderHeight;
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(sliderHeight);
    }];
    [self.progressPassedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.progressView);
    }];
    [self.progressBufferView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.progressView);
    }];
}

- (void)setCurrentValue:(float)currentValue {
    currentValue = currentValue>1.0?1.0:currentValue<0?0:currentValue;
    _currentValue = currentValue;
    CGFloat currentWidth = self.progressView.frame.size.width*currentValue;
    [self.progressPassedView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(currentWidth);
    }];
    [self.sliderButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(currentWidth-kSliderBtnWH/2);
    }];
}

- (void)setBufferValue:(float)bufferValue {
    _bufferValue = bufferValue;
    [self.progressBufferView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.progressView.frame.size.width*bufferValue);
    }];
}

- (void)setThumbImage:(UIImage *)thumbImage forState:(UIControlState)state {
    [self.sliderButton setImage:thumbImage forState:state];
    [self.sliderButton sizeToFit];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state {
    [self.sliderButton setBackgroundImage:backgroundImage forState:state];
    [self.sliderButton sizeToFit];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -10.f, 0);
    return CGRectContainsPoint(bounds, point);
}

@end
