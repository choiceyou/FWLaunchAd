//
//  FWLaunchAdConfiguration.h
//  FWLaunchAd
//
//  Created by xfg on 2018/9/17.
//  Copyright © 2018年 xfg. All rights reserved.
//  启动广告的配置

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "FWLaunchAdCloseBtn.h"
#import "FWLaunchAdImageManager.h"

NS_ASSUME_NONNULL_BEGIN

// 广告默认显示时间
static NSUInteger const adShowDurationDefault = 5;
// 显示完成动画时间默认时间
static CGFloat const showFinishAnimateTimeDefault = 0.8;

/**
 广告显示结束时的动画
 
 - AdShowCompletedAnimateNone: 无动画
 - AdShowCompletedAnimateFadein: 普通淡入(default)
 - AdShowCompletedAnimateLite: 放大淡入
 - AdShowCompletedAnimateFlipFromLeft: 左右翻转(类似网易云音乐)
 - AdShowCompletedAnimateFlipFromBottom: 下上翻转
 - AdShowCompletedAnimateCurlUp: 向上翻页
 */
typedef NS_ENUM(NSInteger, AdShowCompletedAnimate)
{
    AdShowCompletedAnimateNone = 1,
    AdShowCompletedAnimateFadein,
    AdShowCompletedAnimateLite,
    AdShowCompletedAnimateFlipFromLeft,
    AdShowCompletedAnimateFlipFromBottom,
    AdShowCompletedAnimateCurlUp
};

/**
 动态类型的启动广告（gif图片、视频）：播放策略

 - FWLaunchDynamicAdPlayDefault: 循环播放、可传入结束时间
 - FWLaunchDynamicAdPlayCycleOnce: 只播放一次、可传入结束时间
 - FWLaunchDynamicAdPlayCycleOnceFinished: 只播放一次，同时播放结束即消失广告。注意：此时外部传入的Configuration中的duration参数无效
 */
typedef NS_ENUM(NSUInteger, FWLaunchDynamicAdPlayType)
{
    FWLaunchDynamicAdPlayDefault = 0,
    FWLaunchDynamicAdPlayCycleOnce,
    FWLaunchDynamicAdPlayCycleOnceFinished
};


@interface FWLaunchAdConfiguration : NSObject

/**
 停留时间(default 5 ,单位:秒)
 */
@property (nonatomic, assign) NSUInteger duration;

/**
 延迟显示关闭按钮(default 0 ,单位:秒)
 */
@property (nonatomic, assign) NSUInteger waitUntilShowCloseBtn;

/**
 跳过按钮类型(default AdSkipTypeTimeText)
 */
@property (nonatomic, assign) AdSkipType skipButtonType;

/**
 显示完成动画(default AdShowFinishAnimateFadein)
 */
@property (nonatomic, assign) AdShowCompletedAnimate showFinishAnimate;

/**
 显示完成动画时间(default showFinishAnimateTimeDefault, 单位:秒)
 */
@property (nonatomic,assign) CGFloat showFinishAnimateTime;

/**
 设置开屏广告的frame(default [UIScreen mainScreen].bounds)
 */
@property (nonatomic,assign) CGRect frame;

/**
 程序从后台恢复时,是否需要展示广告(defailt NO)
 */
@property (nonatomic,assign) BOOL showEnterForeground;

/**
 禁止点击广告视图(defailt NO)
 */
@property (nonatomic,assign) BOOL forbidClickAdView;

/**
 点击打开页面参数
 */
@property (nonatomic, strong) id openModel;

/**
 动态类型的启动广告（gif图片、视频）：播放策略(default FWLaunchDynamicAdPlayDefault)
 */
@property (nonatomic, assign) FWLaunchDynamicAdPlayType dynamicAdPlayType;

/**
 自定义跳过按钮(若定义此视图,将会自定替换系统跳过按钮)
 */
@property(nonatomic,strong) UIView *customSkipView;

/**
 子视图(若定义此属性,这些视图将会被自动添加在广告视图上,frame相对于window)
 */
@property(nonatomic,copy,nullable) NSArray<UIView *> *subViews;

@end



@interface FWLaunchImageAdConfiguration : FWLaunchAdConfiguration

/**
 image本地图片名(jpg/gif图片请带上扩展名)或网络图片URL string
 */
@property (nonatomic, copy) NSString *imageNameOrURLString;

/**
 图片广告缩放模式(default UIViewContentModeScaleToFill)
 */
@property (nonatomic, assign) UIViewContentMode contentMode;

/**
 缓存机制(default FWLaunchImageDefault)
 */
@property (nonatomic, assign) FWLaunchAdImageOptions imageOption;

+ (FWLaunchImageAdConfiguration *)defaultConfiguration;

@end



@interface FWLaunchVideoAdConfiguration : FWLaunchAdConfiguration

/**
 video本地名或网络链接URL string
 */
@property (nonatomic, copy) NSString *videoNameOrURLString;

/**
 视频缩放模式(default AVLayerVideoGravityResizeAspectFill)
 */
@property (nonatomic, copy) AVLayerVideoGravity videoGravity;

/**
 是否关闭音频(default NO)
 */
@property (nonatomic, assign) BOOL muted;

+ (FWLaunchVideoAdConfiguration *)defaultConfiguration;

@end

NS_ASSUME_NONNULL_END
