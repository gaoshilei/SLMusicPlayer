//
//  SLMusicPlayerController.m
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import "SLMusicPlayerController.h"
#import "SLMusicControlView.h"
#import "SLDiscView.h"
#import "SLPlayer.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface SLMusicModel()

@property (nonatomic, strong) NSURL *songDiscUrl;
@property (nonatomic, strong) NSURL *songBgUrl;

@end
@implementation SLMusicModel

@end

@interface SLMusicPlayerController ()<SLMusicControlDelegate,SLPlayerDelegate>

@property (nonatomic, strong) SLMusicControlView *musicControl;
@property (nonatomic, strong) SLDiscView *discView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UILabel *singerNameLabel;
@property (nonatomic, strong) UIView *navigatorWrapper;
@property (nonatomic, strong) SLPlayer *player;

@end

@implementation SLMusicPlayerController

#pragma mark - life cycle
static SLMusicPlayerController *shareVC = nil;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareVC = [super allocWithZone:zone];
    });
    return shareVC;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareVC = [super init];
    });
    return shareVC;
}

+ (instancetype)shareInstance {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_initSubviews];
    SLMusicModel *model = [SLMusicModel new];
    [self setSongModel:model];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)p_initSubviews {
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.discView];
    [self.view addSubview:self.musicControl];
    
    [self.musicControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20.f);
        make.height.mas_equalTo(160.f);
    }];
    
    CGFloat discTop = [UIApplication sharedApplication].statusBarFrame.size.height + 44;
    [self.discView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(discTop);
        make.bottom.equalTo(self.musicControl.mas_top);
    }];
    

    [self.view addSubview:self.navigatorWrapper];
    CGFloat statusH = [UIApplication sharedApplication].statusBarFrame.size.height;
    [self.navigatorWrapper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(statusH);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(44.f);
    }];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"cm2_act_view_btn_back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"cm2_act_view_btn_back_prs"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(p_backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigatorWrapper addSubview:backBtn];
    backBtn.contentMode = UIViewContentModeScaleAspectFit;
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10.f);
        make.centerY.equalTo(self.navigatorWrapper);
        make.width.height.mas_equalTo(44.f);
    }];
    
    [self.navigatorWrapper addSubview:self.songNameLabel];
    [self.navigatorWrapper addSubview:self.singerNameLabel];
    [self.songNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.navigatorWrapper);
        make.top.equalTo(self.navigatorWrapper).offset(5.f);
    }];
    [self.singerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.navigatorWrapper);
        make.top.equalTo(self.songNameLabel.mas_bottom);
    }];
}

- (void)p_initData {
    [self.bgImageView sd_setImageWithURL:_songModel.songBgUrl placeholderImage:[UIImage imageNamed:@"cm2_fm_bg"]];
    self.discView.imageUrl = _songModel.songDiscUrl;
    self.songNameLabel.text = _songModel.songName;
    self.singerNameLabel.text = _songModel.singerName;
    [self.player setPlayUrlStr:_songModel.songLink];
}

#pragma mark - lazy load

- (SLMusicControlView *)musicControl {
    if (!_musicControl) {
        _musicControl = [[SLMusicControlView alloc] init];
        _musicControl.delegate = self;
    }
    return _musicControl;
}

- (SLDiscView *)discView {
    if (!_discView) {
        _discView = [[SLDiscView alloc] init];
    }
    return _discView;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        UIVisualEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurView.frame = _bgImageView.bounds;
        [_bgImageView addSubview:blurView];
        _bgImageView.image = [UIImage imageNamed:@"cm2_fm_bg"];
    }
    return _bgImageView;
}

- (UILabel *)songNameLabel {
    if (!_songNameLabel) {
        _songNameLabel = [[UILabel alloc] init];
        _songNameLabel.font = [UIFont systemFontOfSize:22.f];
        _songNameLabel.textColor = [UIColor whiteColor];
    }
    return _songNameLabel;
}

- (UILabel *)singerNameLabel {
    if (!_singerNameLabel) {
        _singerNameLabel = [[UILabel alloc] init];
        _singerNameLabel.font = [UIFont systemFontOfSize:12.f];
        _singerNameLabel.textColor = [UIColor whiteColor];
    }
    return _singerNameLabel;
}

- (UIView *)navigatorWrapper {
    if (!_navigatorWrapper) {
        _navigatorWrapper = [[UIView alloc] init];
        _navigatorWrapper.backgroundColor = [UIColor clearColor];
    }
    return _navigatorWrapper;
}

- (SLPlayer *)player {
    if (!_player) {
        _player = [SLPlayer shareInstance];
        _player.delegate = self;
    }
    return _player;
}

#pragma mark - User Interaction

- (void)p_backAction:(UIButton *)sender {
    NSLog(@"%s",__func__);
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Public Method

- (void)setSongModel:(SLMusicModel *)songModel {
    _songModel = songModel;
    /** 测试数据 */
    _songModel.songBgPic = @"http://qukufile2.qianqian.com/data2/pic/046d17bfa056e736d873ec4f891e338f/540336142/540336142.jpg@s_0,w_300";
    _songModel.songDiscPic = @"http://musicdata.baidu.com/data2/pic/4a5941d2143e0fbe1b1fb315fa6bafbf/551079935/551079935.jpg@s_1,w_300,h_300";
    _songModel.songLink = @"http://zhangmenshiting.qianqian.com/data2/music/42613148/305552201600128.mp3?xcode=e8e49774847ac00d2b8f63f9ac723f36";
    _songModel.songName = @"退后";
    _songModel.singerName = @"周杰伦";
    /** 测试数据 */
    _songModel.songBgUrl = [NSURL URLWithString:_songModel.songBgPic];
    _songModel.songDiscUrl = [NSURL URLWithString:_songModel.songDiscPic];
    [self p_initData];
}

#pragma mark - SLMusicControlDelegate

- (void)musicControl:(SLMusicControlView *)control didClickPlay:(UIButton *)playBtn {
    if (!playBtn.selected) {
        [self.player play];
        [self.discView startAnim];
        playBtn.selected = YES;
    }else {
        [self.discView pauseAnim];
        [self.player pause];
        playBtn.selected = NO;
    }
}

#pragma mark - SLPlayerDelegate

- (void)slPlayer:(SLPlayer *)player playerStateChanged:(SLMusicPlayerStatus)status {
    switch (status) {
        case SLMusicPlayerStatusEnded: {
            [self.discView stopAnim];
            [self.player stop];
        }
            break;
        default:
            break;
    }
}

@end
