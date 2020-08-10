//
//  FWLaunchAdConfiguration.m
//  FWLaunchAd
//
//  Created by xfg on 2018/9/17.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWLaunchAdConfiguration.h"

@implementation FWLaunchAdConfiguration

@end


@implementation FWLaunchImageAdConfiguration

+ (FWLaunchImageAdConfiguration *)defaultConfiguration
{
    // 配置广告数据
    FWLaunchImageAdConfiguration *configuration = [FWLaunchImageAdConfiguration new];
    // 广告停留时间
    configuration.duration = adShowDurationDefault;
    // 广告frame
    configuration.frame = [UIScreen mainScreen].bounds;
    // 动态类型的启动广告（gif图片、视频）：播放策略
    configuration.dynamicAdPlayType = FWLaunchDynamicAdPlayDefault;
    // 缓存机制
    configuration.imageOption = FWLaunchAdImageDefault;
    // 图片填充模式
    configuration.contentMode = UIViewContentModeScaleToFill;
    // 广告显示完成动画
    configuration.showFinishAnimate = AdShowCompletedAnimateFadein;
    // 显示完成动画时间
    configuration.showFinishAnimateTime = showFinishAnimateTimeDefault;
    // 动态类型的启动广告（gif图片、视频）：播放策略
    configuration.dynamicAdPlayType = FWLaunchDynamicAdPlayDefault;
    // 跳过按钮类型
    configuration.skipButtonType = AdSkipTypeTimeText;
    // 后台返回时,是否显示广告
    configuration.showEnterForeground = NO;
    // 禁止点击广告视图
    configuration.forbidClickAdView = NO;
    
    return configuration;
}

@end



@implementation FWLaunchVideoAdConfiguration

+ (FWLaunchVideoAdConfiguration *)defaultConfiguration
{
    // 配置广告数据
    FWLaunchVideoAdConfiguration *configuration = [FWLaunchVideoAdConfiguration new];
    // 广告停留时间
    configuration.duration = adShowDurationDefault;
    // 广告frame
    configuration.frame = [UIScreen mainScreen].bounds;
    // 视频填充模式
    configuration.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // 动态类型的启动广告（gif图片、视频）：播放策略
    configuration.dynamicAdPlayType = FWLaunchDynamicAdPlayDefault;
    // 广告显示完成动画
    configuration.showFinishAnimate = AdShowCompletedAnimateFadein;
    // 显示完成动画时间
    configuration.showFinishAnimateTime = showFinishAnimateTimeDefault;
    // 跳过按钮类型
    configuration.skipButtonType = AdSkipTypeTimeText;
    // 后台返回时,是否显示广告
    configuration.showEnterForeground = NO;
    // 是否静音播放
    configuration.muted = NO;
    
    return configuration;
}

@end
