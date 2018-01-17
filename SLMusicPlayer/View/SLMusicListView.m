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
#define kCellHeight 48.f

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
@property (nonatomic, strong) UILabel   *nameLabel;
@property (nonatomic, strong) UIView    *indicator;
@property (nonatomic, assign, setter=setCellSelected:) BOOL isSelected;
@property (nonatomic, copy  ) void (^downloadBlock)(SLMusicModel *model);

@end

@implementation SLMusicListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self p_initSubviews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (void)setCellSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    _indicator.hidden = !isSelected;
    if (isSelected) {
        _nameLabel.textColor = [UIColor colorWithRed:198/255.0 green:81/255.0 blue:64/255.0 alpha:1];
    }else {
        _nameLabel.textColor = [UIColor blackColor];
    }
}

- (void)p_downloadBtnClick:(UIButton *)btn {
    NSLog(@"%s",__func__);
    if (self.downloadBlock) {
        self.downloadBlock(_model);
    }
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
    self.alpha = .95f;
    
    [self.bgwrapper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self);
    }];
}

- (void)didMoveToSuperview {
    CGFloat offsetY = kCellHeight * _currentIndex;
    CGFloat maxOffsetY = kCellHeight*(self.musicList.count+1) - self.listView.frame.size.height;
    if (maxOffsetY<0) {
        return;
    }
    if (offsetY > maxOffsetY) {
        offsetY = maxOffsetY;
    }
    NSLog(@"列表需要偏移的距离为：%.2f",offsetY);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.listView setContentOffset:CGPointMake(0, offsetY) animated:NO];
    });
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
- (void)p_setView:(UIView *)view positionY:(CGFloat)y {
    CGRect frame = view.frame;
    frame.origin.y = y;
    view.frame = frame;
}

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
    cell.isSelected = _currentIndex == indexPath.row;
    __weak typeof(self) weakSelf = self;
    [cell setDownloadBlock:^(SLMusicModel *model) {
        if ([self.delegate respondsToSelector:@selector(downloadBtnClickedAtIndex:currentModel:)]) {
            NSInteger currentIndex = [weakSelf.musicList indexOfObject:model];
            [self.delegate downloadBtnClickedAtIndex:currentIndex currentModel:model];
        }
    }];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectZero];
    header.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 100, kCellHeight)];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(selectItemAtIndex:selectedModel:)]) {
        //取消之前cell的高亮
        SLMusicListCell *highlightedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
        highlightedCell.isSelected = NO;
        //将当前cell设置高亮
        SLMusicListCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        currentCell.isSelected = YES;
        _currentIndex = indexPath.row;
        [self.delegate selectItemAtIndex:_currentIndex selectedModel:currentCell.model];
        [self p_listViewDismiss];
    }
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
