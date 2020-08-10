//
//  FWLaunchImageView.h
//  FWLaunchAd
//
//  Created by xfg on 2018/9/17.
//  Copyright © 2018年 xfg. All rights reserved.
//  启动图

#import <UIKit/UIKit.h>

/**
 启动图来源

 - SourceTypeLaunchImage: LaunchImage(default)
 - SourceTypeLaunchScreen: LaunchScreen.storyboard
 */
typedef NS_ENUM(NSInteger, SourceType)
{
    SourceTypeLaunchImage = 1,
    SourceTypeLaunchScreen
};

@interface FWLaunchImageView : UIImageView

/**
 初始化启动图

 @param sourceType 启动图来源
 @return self
 */
- (instancetype)initWithSourceType:(SourceType)sourceType;

@end
