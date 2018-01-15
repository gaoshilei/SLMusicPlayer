//
//  SLMusicPlayerController.h
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLMusicListView.h"

@protocol SLMusicPlayerDelegate<NSObject>

@end

@interface SLMusicPlayerController : UIViewController

@property (nonatomic, copy) NSArray <SLMusicModel*> *musicList;

+ (instancetype)shareInstance;

@end
