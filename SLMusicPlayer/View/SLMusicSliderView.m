//
//  SLMusicSliderView.m
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#define kSliderBtnWH    19.f
#define kProgressMargin 2.f
#define kProgressW      self.frame.size.width - kProgressMargin*2
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
    __weak typeof(self) weakSelf = self;
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf);
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

@end

@interface SLMusicSliderView()

/**
 滑块背景图片
 */
@property (nonatomic, strong) UIImageView *progressBgView;

/**
 已经播放的进度
 */
@property (nonatomic, strong) UIImageView *progressedView;

/**
 滑块
 */
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
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.progressBgView];
    [self addSubview:self.progressedView];
    [self addSubview:self.sliderButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_sliderTapped:)];
    [self addGestureRecognizer:tap];
    
    self.progressBgView.frame = CGRectMake(kProgressMargin, 0, 0, kProgressH);
    self.progressedView.frame = self.progressBgView.frame;
    self.sliderButton.frame = CGRectMake(0, 0, kSliderBtnWH, kSliderBtnWH);
    [self.sliderButton hideActivityAnim];
}

#pragma mark - lazy load

- (UIImageView *)progressBgView {
    if (!_progressBgView) {
        _progressBgView = [[UIImageView alloc] init];
        _progressBgView.backgroundColor = [UIColor grayColor];
    }
    return _progressBgView;
}

- (UIImageView *)progressedView {
    if (!_progressedView) {
        _progressedView = [[UIImageView alloc] init];
        _progressedView.backgroundColor = [UIColor whiteColor];
    }
    return _progressedView;
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

- (void)p_sliderTapped:(UIButton *)btn {
    
}

- (void)sliderBtnTouchBegin:(UIButton *)btn {
    
//    if ([self.delegate respondsToSelector:@selector(sliderTouchBegin:)]) {
//        [self.delegate sliderTouchBegin:self.value];
//    }
}

- (void)sliderBtnTouchEnded:(UIButton *)btn {
    
//    if ([self.delegate respondsToSelector:@selector(sliderTouchEnded:)]) {
//        [self.delegate sliderTouchEnded:self.value];
//    }
}

- (void)sliderBtnDragMoving:(UIButton *)btn event:(UIEvent *)event {
    
    // 点击的位置
    CGPoint point = [event.allTouches.anyObject locationInView:self];
    
    // 获取进度值 由于btn是从 0-(self.width - btn.width)
    float value = (point.x - btn.frame.size.width * 0.5) / (self.frame.size.width - btn.frame.size.width);
    value = value >= 1.0 ? 1.0 : value <= 0.0 ? 0.0 : value;
//    [self setValue:value];
    
//    if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
//        [self.delegate sliderValueChanged:value];
//    }
}

- (void)tapped:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    
    // 获取进度
    float value = (point.x - self.progressBgView.frame.origin.x) * 1.0 / self.progressBgView.frame.size.width;
    value = value >= 1.0 ? 1.0 : value <= 0 ? 0 : value;
    
//    [self setValue:value];
    
//    if ([self.delegate respondsToSelector:@selector(sliderTapped:)]) {
//        [self.delegate sliderTapped:value];
//    }
}


@end
