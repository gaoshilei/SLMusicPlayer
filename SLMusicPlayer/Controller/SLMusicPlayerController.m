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


@interface SLMusicPlayerController ()<SLMusicControlDelegate,SLPlayerDelegate,SLMusicListDelegate> {
    BOOL _isDragging;
}

@property (nonatomic, strong) SLMusicControlView *musicControl;
@property (nonatomic, strong) SLDiscView *discView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UILabel *singerNameLabel;
@property (nonatomic, strong) UIView *navigatorWrapper;
@property (nonatomic, strong) SLPlayer *player;
@property (nonatomic, assign) double totalTime;
@property (nonatomic, assign) SLPlayerLoopStyle loopStyle;
@property (nonatomic, strong) SLMusicModel *currentModel;
@property (nonatomic, assign) NSInteger initialIndex;

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
    _isDragging = NO;
    _loopStyle = SLPlayerLoopStyleLooping;
    [self p_initSubviews];
    if (!_currentModel) {
        _currentModel = self.musicList[0];
    }
    [self p_initSongData:_currentModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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

- (void)p_initSongData:(SLMusicModel *)model {
    self.discView.imageUrl = [NSURL URLWithString:model.music_picRadio];
    if (!model.music_picRadio || [model.music_picRadio isEqualToString:@""] || [model.music_picRadio isKindOfClass:[NSNull class]]) {
        model.music_cover = model.music_picRadio;
    }
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:model.music_cover] placeholderImage:[UIImage imageNamed:@"cm2_fm_bg"]];
    self.songNameLabel.text = model.music_name;
    self.singerNameLabel.text = model.music_artist;
    [self.player setPlayUrlStr:model.music_link];
    [self p_startPlay];
    self.musicControl.isLike = model.isLike;
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
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
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

- (void)p_stopPlay {
    [self.player stop];
    [self.discView stopAnim];
    [self.musicControl stopPlay];
}

- (void)p_startPlay {
    [self.discView startAnim];
    [self.musicControl startPlay];
    [self.player play];
}

- (void)p_pause {
    [self.discView pauseAnim];
    [self.player pause];
    [self.musicControl stopPlay];
}

- (void)p_loopingSwitchPrev:(BOOL)isPrev {
    NSInteger currentIndex = [self.musicList indexOfObject:_currentModel];
    NSInteger targetIndex;
    if (isPrev) {
        targetIndex = --currentIndex<0?(self.musicList.count-1):currentIndex--;
    }else{
        targetIndex = ++currentIndex>(self.musicList.count-1)?0:currentIndex++;
    }
    _currentModel = self.musicList[targetIndex];
    NSLog(@"===现在播放第%ld首歌曲===",targetIndex+1);
    [self p_switchSongWithModel:_currentModel];
}

- (void)p_singleCycleSwitch {
    [self p_replay];
}

- (void)p_switchSongWithModel:(SLMusicModel *)model {
    if (!model) {
        return;
    }
    [self p_stopPlay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self p_initSongData:model];
    });
}

- (void)p_randomSwitch:(BOOL)isPrev {
    NSInteger currentIndex = [self.musicList indexOfObject:_currentModel];
    NSInteger targetIndex;
    if (isPrev) {
        if (currentIndex == 0) {
            targetIndex = arc4random_uniform((uint32_t)(self.musicList.count-2)) + 1;
        }else {
            targetIndex = arc4random_uniform((uint32_t)currentIndex-1);
        }
    }else {
        if (currentIndex == self.musicList.count-1) {
            targetIndex = arc4random_uniform((uint32_t)(currentIndex-1));
        } else {
            targetIndex = arc4random_uniform((uint32_t)(self.musicList.count-1-currentIndex)) + currentIndex;
            targetIndex = currentIndex?targetIndex+1:targetIndex;
        }
    }
    NSLog(@"random>>>currentIndex：%ld===targetIndex：%ld",currentIndex,targetIndex);
    _currentModel = self.musicList[targetIndex];
    [self p_switchSongWithModel:_currentModel];
}

- (void)p_replay {
    [self p_stopPlay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self p_startPlay];
    });
}

#pragma mark - Public Method

- (void)setMusicList:(NSArray<SLMusicModel *> *)musicList {
    _musicList = musicList;
    if (!_currentModel && _initialIndex && musicList.count>_initialIndex
        ) {
        _currentModel = self.musicList[_initialIndex];
    }
}

- (void)playAtIndex:(NSInteger)index {
    _initialIndex = index;
    if (self.musicList.count>index) {
        _currentModel = self.musicList[index];
    }
}

#pragma mark - SLMusicControlDelegate

- (void)musicControl:(SLMusicControlView *)control didClickPlay:(UIButton *)playBtn {
    if (!playBtn.selected) {
        [self p_startPlay];
    }else {
        [self p_pause];
    }
}
- (void)musicControl:(SLMusicControlView *)control didClickLoop:(UIButton *)loopBtn {
    switch (_loopStyle) {
        case SLPlayerLoopStyleLooping: {
            _loopStyle = SLPlayerLoopStyleSingleCycle;
        }
            break;
        case SLPlayerLoopStyleSingleCycle: {
            _loopStyle = SLPlayerLoopStyleRandom;
        }
            break;
        case SLPlayerLoopStyleRandom: {
            _loopStyle = SLPlayerLoopStyleLooping;
        }
            break;
    }
    self.musicControl.loopStyle = _loopStyle;
}

- (void)p_switchSongsPrev:(BOOL)isPrev {
    switch (_loopStyle) {
        case SLPlayerLoopStyleLooping:
            [self p_loopingSwitchPrev:isPrev];
            break;
        case SLPlayerLoopStyleSingleCycle:
            [self p_singleCycleSwitch];
            break;
        case SLPlayerLoopStyleRandom:
            [self p_randomSwitch:isPrev];
            break;
    }
}

- (void)musicControl:(SLMusicControlView *)control didClickPrevious:(UIButton *)prevBtn {
    [self p_switchSongsPrev:YES];
}

- (void)musicControl:(SLMusicControlView *)control didClickNext:(UIButton *)nextBtn {
    [self p_switchSongsPrev:NO];
}

- (void)musicControl:(SLMusicControlView *)control didClickList:(UIButton *)listBtn {
    SLMusicListView *list = [[SLMusicListView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    list.musicList = self.musicList;
    list.currentModel = _currentModel;
    list.delegate = self;
    [self.view addSubview:list];
    [list showUpList];
}
- (void)musicControl:(SLMusicControlView *)control didClickLike:(UIButton *)likeBtn {
    if ([self.delegate respondsToSelector:@selector(slMusicPlayerClickLike:)]) {
        _currentModel.isLike = !_currentModel.isLike;
        self.musicControl.isLike = _currentModel.isLike;
        [self.delegate slMusicPlayerClickLike:_currentModel];
    }
}
- (void)musicControl:(SLMusicControlView *)control didClickDownload:(UIButton *)downloadBtn {
    if ([self.delegate respondsToSelector:@selector(slMusicPlayerClickDownloadSong:)]) {
        [self.delegate slMusicPlayerClickDownloadSong:_currentModel];
    }
}

- (void)musicControl:(SLMusicControlView *)control didClickMore:(UIButton *)moreBtn {
    if ([self.delegate respondsToSelector:@selector(slMusicPlayerClickMore:)]) {
        [self.delegate slMusicPlayerClickMore:_currentModel];
    }
}

- (void)musicControl:(SLMusicControlView *)control didSliderTapped:(CGFloat)value {
    [self.player setProgress:value];
    self.musicControl.currentValue = value;
    self.musicControl.currentTime = [self.player formatTime:@(self.totalTime*value)];
}

- (void)musicControl:(SLMusicControlView *)control didSliderTouchBegan:(CGFloat)value {
    //拖拽时暂停播放
    [self p_pause];
    _isDragging = YES;
}

- (void)musicControl:(SLMusicControlView *)control didSliderTouchEnded:(CGFloat)value {
    [self.player setProgress:value];
    _isDragging = NO;
    [self p_startPlay];
}

- (void)musicControl:(SLMusicControlView *)control didSliderTouchChanged:(CGFloat)value {
    self.musicControl.currentTime = [self.player formatTime:@(self.totalTime*value)];
    self.musicControl.currentValue = value;
}

#pragma mark - SLPlayerDelegate

- (void)slPlayer:(SLPlayer *)player playerStateChanged:(SLMusicPlayerStatus)status {
    switch (status) {
        case SLMusicPlayerStatusEnded: {
            [self.discView stopAnim];
            [self.player stop];
            [self.musicControl stopPlay];
        }
            break;
        default:
            break;
    }
}

- (void)slPlayer:(SLPlayer *)player formatCurrentTime:(NSString *)currentTimeStr formatTotalTime:(NSString *)totalTimeStr progress:(float)progress {
    if (_isDragging) {
        return;
    }
    self.musicControl.currentValue = progress;
    self.musicControl.currentTime = currentTimeStr;
    self.musicControl.totalTime = totalTimeStr;
}

- (void)slPlayer:(SLPlayer *)player duration:(double)duration {
    self.totalTime = duration;
}

- (void)slPlayerIsPlaying:(SLPlayer *)player {
    [self.musicControl showAndHideBufferIndicator];
}

- (void)slPlayerIsBuffering:(SLPlayer *)player {
    [self.musicControl showAndHideBufferIndicator];
}

#pragma mark - SLMusicListDelegate

- (void)selectItemAtIndex:(NSInteger)index selectedModel:(SLMusicModel *)model {
    _currentModel = model;
    [self p_switchSongWithModel:_currentModel];
}

- (void)downloadBtnClickedAtIndex:(NSInteger)index currentModel:(SLMusicModel *)model {
    if ([self.delegate respondsToSelector:@selector(slMusicPlayerClickDownloadSong:)]) {
        [self.delegate slMusicPlayerClickDownloadSong:model];
    }
}

@end
