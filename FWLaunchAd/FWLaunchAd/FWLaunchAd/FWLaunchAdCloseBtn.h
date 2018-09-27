//
//  FWLaunchAdCloseBtn.h
//  FWLaunchAd
//
//  Created by xfg on 2018/9/17.
//  Copyright © 2018年 xfg. All rights reserved.
//  启动广告的关闭按钮

#import <UIKit/UIKit.h>

/**
 倒计时类型

 - AdSkipTypeNone: 无
 - AdSkipTypeTime: 方形:倒计时
 - AdSkipTypeText: 方形:跳过
 - AdSkipTypeTimeText: 方形:倒计时+跳过 (default)
 - AdSkipTypeRoundTime: 圆形:倒计时
 - AdSkipTypeRoundText: 圆形:跳过
 - AdSkipTypeRoundProgressTime: 圆形:进度圈+倒计时
 - AdSkipTypeRoundProgressText: 圆形:进度圈+跳过
 */
typedef NS_ENUM(NSInteger, AdSkipType)
{
    AdSkipTypeNone = 1,
    AdSkipTypeTime,
    AdSkipTypeText,
    AdSkipTypeTimeText,
    AdSkipTypeRoundTime,
    AdSkipTypeRoundText,
    AdSkipTypeRoundProgressTime,
    AdSkipTypeRoundProgressText
};

@interface FWLaunchAdCloseBtn : UIButton

/**
 初始化方法

 @param skipType 倒计时类型
 @return self
 */
- (instancetype)initWithSkipType:(AdSkipType)skipType;

/**
 开始环形递减的进度条

 @param duration 总时间
 */
- (void)startRoundDispathTimerWithDuration:(CGFloat)duration;

/**
 设置关闭按钮上显示的文字

 @param skipType 倒计时类型
 @param duration 总时间
 */
- (void)setTitleWithSkipType:(AdSkipType)skipType duration:(NSInteger)duration;

@end
