//
//  SLDiscView.m
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import "SLDiscView.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>

@interface SLDiscView()

/**唱片*/
@property (nonatomic, strong) UIImageView   *discImageView;
/**歌曲封面图*/
@property (nonatomic, strong) UIImageView   *imageView;
/**定时器*/
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation SLDiscView

- (instancetype)init {
    if (self = [super init]) {
        [self p_initSubview];
    }
    return self;
}

- (void)p_initSubview {
    [self addSubview:self.discImageView];
    [self.discImageView addSubview:self.imageView];
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat discWH = screenW - 80.f;
    CGFloat imgWH = discWH - 50*2.f;
    [self.discImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(66.f);
        make.width.height.mas_equalTo(discWH);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.discImageView);
        make.width.height.mas_equalTo(imgWH);
    }];
    self.imageView.layer.cornerRadius = imgWH * .5f;
}

- (void)setImageUrl:(NSURL *)imageUrl {
    _imageUrl = imageUrl;
    [self.imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"cm2_fm_bg"]];
}

#pragma mark - lazy load
- (UIImageView *)discImageView {
    if (!_discImageView) {
        _discImageView = [[UIImageView alloc] init];
        _discImageView.image = [UIImage imageNamed:@"cm2_play_disc"];
    }
    return _discImageView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

#pragma mark - public method
- (void)startAnim {
    if (!self.displayLink) {
        //停止状态下开始动画
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_execAnimation)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }else {
        //暂停状态下开始动画
        if (self.displayLink.isPaused) {
            [self.displayLink setPaused:NO];
        }
    }
}

- (void)pauseAnim {
    //当前处于播放状态可以暂停
    if (self.displayLink && !self.displayLink.isPaused) {
        [self.displayLink setPaused:YES];
    }
}

- (void)stopAnim {
    //当前处于播放或暂停状态可以停止
    if (self.displayLink) {
        [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [self.displayLink invalidate];
        self.displayLink = nil;
        self.discImageView.transform = CGAffineTransformIdentity;
    }
}

#pragma mark - private method
- (void)p_execAnimation {
    /**
     1秒转过的角度为 360/4/350*60 = 15.4度，可以通过系数来改变旋转的速度
     */
    CGFloat coefficient = 350;
    self.discImageView.transform = CGAffineTransformRotate(self.discImageView.transform, M_PI_4/coefficient);
}

@end
