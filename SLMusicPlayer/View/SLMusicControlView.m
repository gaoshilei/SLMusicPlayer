//
//  SLMusicControlView.m
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import "SLMusicControlView.h"
#import "SLMusicSliderView.h"

const CGFloat topWrapperH       = 50.f;
const CGFloat sliderWrapperH    = 30.f;
const CGFloat bottomWrapperH    = 75.f;

@interface SLMusicControlView()<SLMusicSliderDelegate> {
    BOOL _isBuffering;
}

@property (nonatomic, strong) UIButton  *likeBtn;
@property (nonatomic, strong) UIButton  *downloadBtn;
@property (nonatomic, strong) UIButton  *moreBtn;
@property (nonatomic, strong) UIView    *topWrapper;

@property (nonatomic, strong) UILabel   *currentLabel;
@property (nonatomic, strong) UILabel   *totalLabel;
@property (nonatomic, strong) UIView    *sliderWrapper;
@property (nonatomic, strong) SLMusicSliderView *slider;

@property (nonatomic, strong) UIButton  *loopBtn;
@property (nonatomic, strong) UIButton  *prevBtn;
@property (nonatomic, strong) UIButton  *playBtn;
@property (nonatomic, strong) UIButton  *nextBtn;
@property (nonatomic, strong) UIButton  *listBtn;
@property (nonatomic, strong) UIView    *bottomWrapper;

@end

@implementation SLMusicControlView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        [self p_initSubviews];
    }
    return self;
}

- (void)p_initSubviews {
    
    [self addSubview:self.topWrapper];
    [self addSubview:self.sliderWrapper];
    [self addSubview:self.bottomWrapper];
    
    [self.topWrapper addSubview:self.likeBtn];
    [self.topWrapper addSubview:self.downloadBtn];
    [self.topWrapper addSubview:self.moreBtn];
    
    [self.sliderWrapper addSubview:self.currentLabel];
    [self.sliderWrapper addSubview:self.totalLabel];
    [self.sliderWrapper addSubview:self.slider];
    
    [self.bottomWrapper addSubview:self.loopBtn];
    [self.bottomWrapper addSubview:self.prevBtn];
    [self.bottomWrapper addSubview:self.playBtn];
    [self.bottomWrapper addSubview:self.nextBtn];
    [self.bottomWrapper addSubview:self.listBtn];
    
    [self.topWrapper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(topWrapperH);
    }];
    [self.sliderWrapper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.topWrapper.mas_bottom);
        make.height.mas_equalTo(sliderWrapperH);
    }];
    [self.bottomWrapper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.sliderWrapper.mas_bottom);
    }];
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat btnWH = topWrapperH;
    CGFloat LRMargin = 50.f;
    CGFloat marginSpace = (screenW - LRMargin*2 - btnWH*3) / 2;
    
    //顶部区域
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.topWrapper);
        make.width.mas_equalTo(btnWH);
        make.left.equalTo(self.topWrapper).offset(LRMargin);
    }];
    [self.downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.width.equalTo(self.likeBtn);
        make.left.equalTo(self.likeBtn.mas_right).offset(marginSpace);
    }];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.width.equalTo(self.likeBtn);
        make.right.equalTo(self.topWrapper).offset(-LRMargin);
    }];
    //滑块区域
    [self.currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.sliderWrapper);
        make.left.equalTo(self.sliderWrapper).offset(15.f);
        make.right.equalTo(self.slider.mas_left).offset(-10.f);
    }];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.sliderWrapper);
        make.right.equalTo(self.sliderWrapper).offset(-15.f);
        make.left.equalTo(self.slider.mas_right).offset(10.f);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.sliderWrapper);
        make.left.equalTo(self.sliderWrapper).offset(75.f);
        make.right.equalTo(self.sliderWrapper).offset(-75.f);
    }];
    [self.currentLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.totalLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.slider setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    //播放控制区域
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomWrapper);
    }];
    [self.prevBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.playBtn.mas_left).offset(-20.f);
        make.centerY.equalTo(self.bottomWrapper);
    }];
    [self.loopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.prevBtn.mas_left).offset(-20.f);
        make.centerY.equalTo(self.bottomWrapper);
    }];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playBtn.mas_right).offset(20.f);
        make.centerY.equalTo(self.bottomWrapper);
    }];
    [self.listBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nextBtn.mas_right).offset(20.f);
        make.centerY.equalTo(self.bottomWrapper);
    }];
}

#pragma mark - lazy load
- (UIView *)topWrapper {
    if (!_topWrapper) {
        _topWrapper = [[UIView alloc] init];
        _topWrapper.backgroundColor = [UIColor clearColor];
    }
    return _topWrapper;
}

- (UIView *)sliderWrapper {
    if (!_sliderWrapper) {
        _sliderWrapper = [[UIView alloc] init];
        _sliderWrapper.backgroundColor = [UIColor clearColor];
    }
    return _sliderWrapper;
}

- (UIView *)bottomWrapper {
    if (!_bottomWrapper) {
        _bottomWrapper = [[UIView alloc] init];
        _bottomWrapper.backgroundColor = [UIColor clearColor];
    }
    return _bottomWrapper;
}

- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_likeBtn setImage:[UIImage imageNamed:@"cm2_play_icn_love"] forState:UIControlStateNormal];
        [_likeBtn setImage:[UIImage imageNamed:@"cm2_play_icn_love_prs"] forState:UIControlStateHighlighted];
        [_likeBtn addTarget:self action:@selector(p_likeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeBtn;
}

- (UIButton *)downloadBtn {
    if (!_downloadBtn) {
        _downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadBtn setImage:[UIImage imageNamed:@"cm2_icn_dld"] forState:UIControlStateNormal];
        [_downloadBtn setImage:[UIImage imageNamed:@"cm2_icn_dld_prs"] forState:UIControlStateHighlighted];
        [_downloadBtn addTarget:self action:@selector(p_downloadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setImage:[UIImage imageNamed:@"cm2_play_icn_more"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"cm2_play_icn_more_prs"] forState:UIControlStateHighlighted];
        [_moreBtn addTarget:self action:@selector(p_moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (UIButton *)loopBtn {
    if (!_loopBtn) {
        _loopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loopBtn setImage:[UIImage imageNamed:@"cm2_icn_loop"] forState:UIControlStateNormal];
        [_loopBtn setImage:[UIImage imageNamed:@"cm2_icn_loop_prs"] forState:UIControlStateHighlighted];
        [_loopBtn addTarget:self action:@selector(p_loopBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loopBtn;
}

- (UIButton *)prevBtn {
    if (!_prevBtn) {
        _prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_prevBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_previous"] forState:UIControlStateNormal];
        [_prevBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_previous_prs"] forState:UIControlStateHighlighted];
        [_prevBtn addTarget:self action:@selector(p_prevBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _prevBtn;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_next"] forState:UIControlStateNormal];
        [_nextBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_next_prs"] forState:UIControlStateHighlighted];
        [_nextBtn addTarget:self action:@selector(p_nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"cm2_fm_btn_pause"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(p_playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)listBtn {
    if (!_listBtn) {
        _listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_listBtn setImage:[UIImage imageNamed:@"cm2_icn_list"] forState:UIControlStateNormal];
        [_listBtn setImage:[UIImage imageNamed:@"cm2_icn_list_prs"] forState:UIControlStateHighlighted];
        [_listBtn addTarget:self action:@selector(p_listBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _listBtn;
}

- (UILabel *)currentLabel {
    if (!_currentLabel) {
        _currentLabel = [[UILabel alloc] init];
        _currentLabel.textColor = [UIColor whiteColor];
        _currentLabel.text = @"00:00";
        _currentLabel.adjustsFontSizeToFitWidth = YES;
        _currentLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _currentLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentLabel;
}

- (UILabel *)totalLabel {
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] init];
        _totalLabel.textColor = [UIColor whiteColor];
        _totalLabel.text = @"00:00";
        _totalLabel.adjustsFontSizeToFitWidth = YES;
        _totalLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _totalLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalLabel;
}

- (SLMusicSliderView *)slider {
    if (!_slider) {
        _slider = [[SLMusicSliderView alloc] init];
        [_slider setBackgroundImage:[UIImage imageNamed:@"cm2_fm_playbar_btn"] forState:UIControlStateNormal];
        [_slider setBackgroundImage:[UIImage imageNamed:@"cm2_fm_playbar_btn"] forState:UIControlStateSelected];
        [_slider setBackgroundImage:[UIImage imageNamed:@"cm2_fm_playbar_btn"] forState:UIControlStateHighlighted];
        [_slider setThumbImage:[UIImage imageNamed:@"cm2_fm_playbar_btn_dot"] forState:UIControlStateNormal];
        [_slider setThumbImage:[UIImage imageNamed:@"cm2_fm_playbar_btn_dot"] forState:UIControlStateSelected];
        [_slider setThumbImage:[UIImage imageNamed:@"cm2_fm_playbar_btn_dot"] forState:UIControlStateHighlighted];
        _slider.maximumTrackImage = [UIImage imageNamed:@"cm2_fm_playbar_bg"];
        _slider.minimumTrackImage = [UIImage imageNamed:@"cm2_fm_playbar_curr"];
        _slider.bufferTrackImage  = [UIImage imageNamed:@"cm2_fm_playbar_ready"];
        _slider.delegate = self;
    }
    return _slider;
}

#pragma mark - User Interaction

- (void)p_likeBtnClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(musicControl:didClickLike:)]) {
        [self.delegate musicControl:self didClickLike:button];
    }
    NSLog(@"%s",__func__);
}

- (void)p_downloadBtnClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(musicControl:didClickDownload:)]) {
        [self.delegate musicControl:self didClickDownload:button];
    }
    NSLog(@"%s",__func__);
}

- (void)p_moreBtnClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(musicControl:didClickMore:)]) {
        [self.delegate musicControl:self didClickMore:button];
    }
    NSLog(@"%s",__func__);
}

- (void)p_loopBtnClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(musicControl:didClickLoop:)]) {
        [self.delegate musicControl:self didClickLoop:button];
    }
    NSLog(@"%s",__func__);
}

- (void)p_prevBtnClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(musicControl:didClickPrevious:)]) {
        [self.delegate musicControl:self didClickPrevious:button];
    }
    NSLog(@"%s",__func__);
}

- (void)p_playBtnClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(musicControl:didClickPlay:)]) {
        [self.delegate musicControl:self didClickPlay:button];
    }
    NSLog(@"%s",__func__);
}

- (void)p_nextBtnClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(musicControl:didClickNext:)]) {
        [self.delegate musicControl:self didClickNext:button];
    }
    NSLog(@"%s",__func__);
}

- (void)p_listBtnClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(musicControl:didClickList:)]) {
        [self.delegate musicControl:self didClickList:button];
    }
    NSLog(@"%s",__func__);
}

#pragma mark - public method
- (void)showAndHideBufferIndicator {
    if (_isBuffering) {
        _isBuffering = NO;
        [self.slider hideBufferIndicator];
    }else{
        _isBuffering = YES;
        [self.slider showBufferIndicator];
    }
}

- (void)stopPlay {
    self.playBtn.selected = NO;
    self.totalTime = nil;
}

- (void)startPlay {
    self.playBtn.selected = YES;
}

- (void)setCurrentTime:(NSString *)currentTime {
    _currentTime = currentTime;
    self.currentLabel.text = currentTime;
}

- (void)setTotalTime:(NSString *)totalTime {
    if (_totalTime) {
        return;
    }
    _totalTime = totalTime;
    self.totalLabel.text = totalTime;
}

- (void)setCurrentValue:(CGFloat)currentValue {
    _currentValue = currentValue;
    self.slider.currentValue = currentValue;
}

#pragma mark - SLMusicSliderDelegate
- (void)slSlider:(SLMusicSliderView *)slider didTappedProgress:(CGFloat)progress {
    if ([self.delegate respondsToSelector:@selector(musicControl:didSliderTapped:)]) {
        [self.delegate musicControl:self didSliderTapped:progress];
    }
}

- (void)slSlider:(SLMusicSliderView *)slider didTouchBegan:(CGFloat)value {
    if ([self.delegate respondsToSelector:@selector(musicControl:didSliderTouchBegan:)]) {
        [self.delegate musicControl:self didSliderTouchBegan:value];
    }
}

- (void)slSlider:(SLMusicSliderView *)slider didTouchEndded:(CGFloat)value {
    if ([self.delegate respondsToSelector:@selector(musicControl:didSliderTouchEnded:)]) {
        [self.delegate musicControl:self didSliderTouchEnded:value];
    }
}

- (void)slSlider:(SLMusicSliderView *)slider didDragChangeValue:(CGFloat)value {
    if ([self.delegate respondsToSelector:@selector(musicControl:didSliderTouchChanged:)]) {
        [self.delegate musicControl:self didSliderTouchChanged:value];
    }
}

@end
