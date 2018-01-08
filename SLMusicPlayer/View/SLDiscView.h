//
//  SLDiscView.h
//  SLMusicPlayer
//
//  Created by gaoshilei on 2018/1/3.
//  Copyright © 2018年 gaoshilei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLDiscView : UIView

/**
 唱片封面图片url
 */
@property (nonatomic, copy  ) NSURL  *imageUrl;

/**
 开始旋转唱片
 */
- (void)startAnim;

/**
 暂停旋转唱片
 */
- (void)pauseAnim;

/**
 停止旋转唱片
 */
- (void)stopAnim;

@end
