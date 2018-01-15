//
//  SLMusicListView.m
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/15.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import "SLMusicListView.h"
#import <objc/message.h>
#import <Masonry.h>
#import "SLMusicPlayerController.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

static const NSString *SLMusicReuseCellIdentifier = @"SLMusicReuseCellIdentifier";

@interface SLMusicModel()

@end

@implementation SLMusicModel

- (NSString *)description {
    unsigned int count;
    const char *className = object_getClassName(self);
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%s : %p>:[\n",className,self];
    Class class = object_getClass(self);
    Ivar *ivarList = class_copyIvarList(class, &count);
    for (unsigned int i=0; i<count; i++) {
        Ivar ivar = ivarList[i];
        NSString *name = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        const char *type = ivar_getTypeEncoding(ivar);
        id value = [self valueForKey:name];
        if (0==strcmp(type, "B")) {
            value = value?@"YES":@"NO";
        }
        [description appendFormat:@"\t%@: %@\n",[self p_deleteUnderline:name],value];
    }
    free(ivarList);
    [description appendString:@"]"];
    return description;
}

- (NSString *)p_deleteUnderline:(NSString *)string {
    if ([string hasPrefix:@"_"]) {
        string = [string substringFromIndex:1];
    }
    return string;
}

@end


@interface SLMusicListCell : UITableViewCell

@property (nonatomic, strong) SLMusicModel *model;
@property (nonatomic, assign) BOOL isHightlighted;
@property (nonatomic, strong) UILabel   *nameLabel;
@property (nonatomic, strong) UIView    *indicator;


@end

@implementation SLMusicListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self p_initSubviews];
    }
    return self;
}

- (void)p_initSubviews {
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:16.f];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(30.f);
    }];
    
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadBtn setImage:[UIImage imageNamed:@"list_download"] forState:UIControlStateNormal];
    [downloadBtn setImage:[UIImage imageNamed:@"list_download"] forState:UIControlStateHighlighted];
    [downloadBtn addTarget:self action:@selector(p_downloadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:downloadBtn];
    
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-20.f);
    }];
    
    _indicator = [[UIView alloc] init];
    _indicator.backgroundColor = [UIColor colorWithRed:198/255.0 green:81/255.0 blue:64/255.0 alpha:1];
    [self.contentView addSubview:_indicator];
    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(8.f);
        make.bottom.equalTo(self.contentView).offset(-8.f);
        make.width.mas_equalTo(3.f);
    }];
    _indicator.hidden = YES;
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(.5f);
    }];
}

- (void)setModel:(SLMusicModel *)model {
    _model = model;
    _nameLabel.text = model.music_name;
    _nameLabel.textColor = [UIColor blackColor];
    _indicator.hidden = YES;
}

- (void)setIsHightlighted:(BOOL)isHightlighted {
    _isHightlighted = isHightlighted;
    _indicator.hidden = !isHightlighted;
    if (_isHightlighted) {
        _nameLabel.textColor = [UIColor colorWithRed:198/255.0 green:81/255.0 blue:64/255.0 alpha:1];
    }
}

- (void)p_downloadBtnClick:(UIButton *)btn {
    NSLog(@"%s",__func__);
}

@end

@interface SLMusicListView()<UITableViewDelegate, UITableViewDataSource> {
    NSUInteger _currentIndex;
}

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) UIView *bgwrapper;

@end

@implementation SLMusicListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self p_initSubviews];
    }
    return self;
}

- (void)p_initSubviews {
    
    [self addSubview:self.bgwrapper];
    [self addSubview:self.listView];
    
    [self.bgwrapper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self);
    }];
}

#pragma mark - lazy load
- (UITableView *)listView {
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, kScreenH, kScreenW, kScreenH/2)];
        _listView.backgroundColor = [UIColor whiteColor];
        _listView.dataSource = self;
        _listView.delegate = self;
        [_listView registerClass:[SLMusicListCell class] forCellReuseIdentifier:SLMusicReuseCellIdentifier.copy];
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _listView;
}

- (UIView *)bgwrapper {
    if (!_bgwrapper) {
        _bgwrapper = [[UIView alloc] init];
        _bgwrapper.backgroundColor = [UIColor blackColor];
        _bgwrapper.alpha = .35f;
        _bgwrapper.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_listViewDismiss)];
        [_bgwrapper addGestureRecognizer:tap];
    }
    return _bgwrapper;
}

#pragma mark - private method

- (void)p_listViewDismiss {
    [UIView animateWithDuration:.35f animations:^{
        [self p_setView:self.listView positionY:kScreenH];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musicList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SLMusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:SLMusicReuseCellIdentifier.copy forIndexPath:indexPath];
    if (!cell) {
        cell = [[SLMusicListCell alloc] init];
    }
    cell.model = self.musicList[indexPath.row];
    cell.isHightlighted = _currentIndex == indexPath.row;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 100, 48)];
    [header addSubview:titleLabel];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"播放列表";
    titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    titleLabel.textColor = [UIColor blackColor];
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    [header addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(header);
        make.height.mas_equalTo(.5f);
    }];
    return header;
}

- (void)p_setView:(UIView *)view positionY:(CGFloat)y {
    CGRect frame = view.frame;
    frame.origin.y = y;
    view.frame = frame;
}

#pragma mark - public method
- (void)setCurrentModel:(SLMusicModel *)currentModel {
    _currentModel = currentModel;
    _currentIndex = [self.musicList indexOfObject:currentModel];
}

- (void)setMusicList:(NSArray<SLMusicModel *> *)musicList {
    _musicList = musicList;
    _currentIndex = [musicList indexOfObject:_currentModel];
}

- (void)showUpList {
    [UIView animateWithDuration:.35f animations:^{
        [self p_setView:self.listView positionY:kScreenH/2];
    } completion:^(BOOL finished) {
        
    }];
}

@end
