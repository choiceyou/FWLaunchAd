//
//  FWLaunchAdManager.m
//  FWLaunchAd
//
//  Created by xfg on 2018/9/26.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWLaunchAdManager.h"
#import <UIKit/UIKit.h>
#import "FWLaunchAd.h"
#import "Network.h"
#import "LaunchAdModel.h"

/** 以下连接供测试使用 */

/** 静态图 */
#define imageURL1 @"http://yun.it7090.com/image/XHLaunchAd/pic_test01.jpg"

/** 动态图 */
#define imageURL3 @"http://yun.it7090.com/image/XHLaunchAd/gif_test01.gif"

/** 视频链接 */
#define videoURL1 @"http://yun.it7090.com/video/XHLaunchAd/video_test01.mp4"


@implementation FWLaunchAdManager

+ (void)load
{
    [self shareManager];
}

+ (FWLaunchAdManager *)shareManager
{
    static FWLaunchAdManager *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[FWLaunchAdManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 在UIApplicationDidFinishLaunching时初始化开屏广告,做到对业务层无干扰,当然你也可以直接在AppDelegate didFinishLaunchingWithOptions方法中初始化
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            // 初始化开屏广告
            [self setupFWLaunchAd];
        }];
    }
    return self;
}

- (void)setupFWLaunchAd
{
    /** 1.图片开屏广告 - 网络数据 */
    //    [self example01];
    
    //2.******图片开屏广告 - 本地数据******
    [self example02];
    
    //3.******视频开屏广告 - 网络数据(网络视频只支持缓存OK后下次显示,看效果请二次运行)******
    //[self example03];
    
    /** 4.视频开屏广告 - 本地数据 */
    //[self example04];
    
    /** 5.如需自定义跳过按钮,请看这个示例 */
    //[self example05];
    
    /** 6.使用默认配置快速初始化,请看下面两个示例 */
    //[self example06];//图片
    //[self example07];//视频
    
    /** 7.如果你想提前批量缓存图片/视频请看下面两个示例 */
    //[self batchDownloadImageAndCache]; //批量下载并缓存图片
    //[self batchDownloadVideoAndCache]; //批量下载并缓存视频
}

#pragma mark - 图片开屏广告-网络数据-示例
- (void)example01
{
    // 设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [FWLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    // 1.因为数据请求是异步的,请在数据请求前,调用下面方法配置数据等待时间.
    // 2.设为3即表示:启动页将停留3s等待服务器返回广告数据,3s内等到广告数据,将正常显示广告,否则将不显示
    // 3.数据获取成功,配置广告数据后,自动结束等待,显示广告
    // 注意:请求广告数据前,必须设置此属性,否则会先进入window的的根控制器
    [FWLaunchAd setWaitDataDuration:3];
    
    // 广告数据请求
    [Network getLaunchAdImageDataSuccess:^(NSDictionary * response) {
        NSLog(@"广告数据 = %@",response);
        // 广告数据转模型
        LaunchAdModel *model = [[LaunchAdModel alloc] initWithDict:response[@"data"]];
        // 配置广告数据
        FWLaunchImageAdConfiguration *imageAdconfiguration = [[FWLaunchImageAdConfiguration alloc] init];
        // 广告停留时间
        imageAdconfiguration.duration = model.duration;
        // 广告frame
        imageAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.8);
        // 广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
        imageAdconfiguration.imageNameOrURLString = model.content;
        // 动态类型的启动广告（gif图片、视频）：播放策略
        imageAdconfiguration.dynamicAdPlayType = FWLaunchDynamicAdPlayCycleOnceFinished;
        // 缓存机制(仅对网络图片有效)
        // 为告展示效果更好,可设置为FWLaunchAdImageCacheInBackground,先缓存,下次显示
        imageAdconfiguration.imageOption = FWLaunchAdImageDefault;
        // 图片填充模式
        imageAdconfiguration.contentMode = UIViewContentModeScaleAspectFill;
        // 广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
        imageAdconfiguration.openModel = model.openUrl;
        // 广告显示完成动画
        imageAdconfiguration.showFinishAnimate = AdShowCompletedAnimateLite;
        // 广告显示完成动画时间
        imageAdconfiguration.showFinishAnimateTime = 0.8;
        // 跳过按钮类型
        imageAdconfiguration.skipButtonType = AdSkipTypeRoundProgressText;
        // 后台返回时,是否显示广告
        imageAdconfiguration.showEnterForeground = NO;
        
        //        //图片已缓存 - 显示一个 "已预载" 视图 (可选)
        //        if([FWLaunchAd checkImageInCacheWithURL:[NSURL URLWithString:model.content]])
        //        {
        //            //设置要添加的自定义视图(可选)
        //            imageAdconfiguration.subViews = [self launchAdSubViews_alreadyView];
        //        }
        // 显示开屏广告
        [FWLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 图片开屏广告-本地数据-示例
- (void)example02
{
    // 设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [FWLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    // 配置广告数据
    FWLaunchImageAdConfiguration *imageAdconfiguration = [FWLaunchImageAdConfiguration new];
    // 广告停留时间
    imageAdconfiguration.duration = 5;
    // 广告frame
    imageAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.8);
    // 广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
    imageAdconfiguration.imageNameOrURLString = @"image2.jpg";
    // 动态类型的启动广告（gif图片、视频）：播放策略
    imageAdconfiguration.dynamicAdPlayType = FWLaunchDynamicAdPlayCycleOnceFinished;
    // 图片填充模式
    imageAdconfiguration.contentMode = UIViewContentModeScaleAspectFill;
    // 广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    imageAdconfiguration.openModel = @"http://www.it7090.com";
    // 广告显示完成动画
    imageAdconfiguration.showFinishAnimate = AdShowCompletedAnimateFlipFromLeft;
    // 广告显示完成动画时间
    imageAdconfiguration.showFinishAnimateTime = 0.8;
    // 跳过按钮类型
    imageAdconfiguration.skipButtonType = AdSkipTypeRoundProgressText;
    // 后台返回时,是否显示广告
    imageAdconfiguration.showEnterForeground = NO;
    // 设置要添加的子视图(可选)
    // imageAdconfiguration.subViews = [self launchAdSubViews];
    // 显示开屏广告
    [FWLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
}

#pragma mark - 视频开屏广告-网络数据-示例
- (void)example03
{
    // 设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [FWLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    // 1.因为数据请求是异步的,请在数据请求前,调用下面方法配置数据等待时间.
    // 2.设为3即表示:启动页将停留3s等待服务器返回广告数据,3s内等到广告数据,将正常显示广告,否则将不显示
    // 3.数据获取成功,配置广告数据后,自动结束等待,显示广告
    // 注意:请求广告数据前,必须设置此属性,否则会先进入window的的根控制器
    [FWLaunchAd setWaitDataDuration:3];
    
    // 广告数据请求
    [Network getLaunchAdVideoDataSuccess:^(NSDictionary * response) {
        
        NSLog(@"广告数据 = %@",response);
        
        // 广告数据转模型
        LaunchAdModel *model = [[LaunchAdModel alloc] initWithDict:response[@"data"]];
        
        // 配置广告数据
        FWLaunchVideoAdConfiguration *videoAdconfiguration = [FWLaunchVideoAdConfiguration new];
        // 广告停留时间
        videoAdconfiguration.duration = model.duration;
        // 广告frame
        videoAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        // 广告视频URLString/或本地视频名(请带上后缀)
        // 注意:视频广告只支持先缓存,下次显示(看效果请二次运行)
        videoAdconfiguration.videoNameOrURLString = model.content;
        // 是否关闭音频
        videoAdconfiguration.muted = NO;
        // 视频缩放模式
        videoAdconfiguration.videoGravity = AVLayerVideoGravityResizeAspectFill;
        // 动态类型的启动广告（gif图片、视频）：播放策略
        videoAdconfiguration.dynamicAdPlayType = FWLaunchDynamicAdPlayDefault;
        // 广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
        videoAdconfiguration.openModel = model.openUrl;
        // 广告显示完成动画
        videoAdconfiguration.showFinishAnimate = AdShowCompletedAnimateFadein;
        // 广告显示完成动画时间
        videoAdconfiguration.showFinishAnimateTime = 0.8;
        // 后台返回时,是否显示广告
        videoAdconfiguration.showEnterForeground = NO;
        // 跳过按钮类型
        videoAdconfiguration.skipButtonType = AdSkipTypeTimeText;
        //视频已缓存 - 显示一个 "已预载" 视图 (可选)
        //        if([FWLaunchAd checkVideoInCacheWithURL:[NSURL URLWithString:model.content]])
        //        {
        //            //设置要添加的自定义视图(可选)
        //            videoAdconfiguration.subViews = [self launchAdSubViews_alreadyView];
        //        }
        
        [FWLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguration delegate:self];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 视频开屏广告-本地数据-示例
- (void)example04
{
    // 设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [FWLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    // 配置广告数据
    FWLaunchVideoAdConfiguration *videoAdconfiguration = [FWLaunchVideoAdConfiguration new];
    // 广告停留时间
    videoAdconfiguration.duration = 3;
    // 广告frame
    videoAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    // 广告视频URLString/或本地视频名(请带上后缀)
    videoAdconfiguration.videoNameOrURLString = @"video2.mp4";
    // 是否关闭音频
    videoAdconfiguration.muted = NO;
    // 视频填充模式
    videoAdconfiguration.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // 动态类型的启动广告（gif图片、视频）：播放策略
    videoAdconfiguration.dynamicAdPlayType = FWLaunchDynamicAdPlayCycleOnceFinished;
    // 广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    videoAdconfiguration.openModel =  @"http://www.it7090.com";
    // 跳过按钮类型
    videoAdconfiguration.skipButtonType = AdSkipTypeRoundProgressTime;
    // 广告显示完成动画
    videoAdconfiguration.showFinishAnimate = AdShowCompletedAnimateLite;
    // 广告显示完成动画时间
    videoAdconfiguration.showFinishAnimateTime = 0.8;
    // 后台返回时,是否显示广告
    videoAdconfiguration.showEnterForeground = NO;
    // 设置要添加的子视图(可选)
    // videoAdconfiguration.subViews = [self launchAdSubViews];
    // 显示开屏广告
    [FWLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguration delegate:self];
}

#pragma mark - 自定义跳过按钮-示例
- (void)example05
{
    // 注意:
    // 1.自定义跳过按钮很简单,configuration有一个customSkipView属性.
    // 2.自定义一个跳过的view 赋值给configuration.customSkipView属性便可替换默认跳过按钮,如下:
    
    // 设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [FWLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    // 配置广告数据
    FWLaunchImageAdConfiguration *imageAdconfiguration = [FWLaunchImageAdConfiguration new];
    // 广告停留时间
    imageAdconfiguration.duration = 5;
    // 广告frame
    imageAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width/1242*1786);
    // 广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
    imageAdconfiguration.imageNameOrURLString = @"image11.gif";
    // 缓存机制(仅对网络图片有效)
    imageAdconfiguration.imageOption = FWLaunchAdImageDefault;
    // 图片填充模式
    imageAdconfiguration.contentMode = UIViewContentModeScaleToFill;
    // 广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    imageAdconfiguration.openModel = @"http://www.it7090.com";
    // 广告显示完成动画
    imageAdconfiguration.showFinishAnimate = AdShowCompletedAnimateFlipFromLeft;
    // 广告显示完成动画时间
    imageAdconfiguration.showFinishAnimateTime = 0.8;
    // 后台返回时,是否显示广告
    imageAdconfiguration.showEnterForeground = NO;
    
    //    //设置要添加的子视图(可选)
    //    imageAdconfiguration.subViews = [self launchAdSubViews];
    //
    //    //start********************自定义跳过按钮**************************
    //    imageAdconfiguration.customSkipView = [self customSkipView];
    //    //********************自定义跳过按钮*****************************end
    
    // 显示开屏广告
    [FWLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
}

#pragma mark - 使用默认配置快速初始化 - 示例
/**
 *  图片
 */
- (void)example06
{
    // 设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [FWLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    // 使用默认配置
    FWLaunchImageAdConfiguration *imageAdconfiguration = [FWLaunchImageAdConfiguration defaultConfiguration];
    // 广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
    imageAdconfiguration.imageNameOrURLString = imageURL3;
    // 广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    imageAdconfiguration.openModel = @"http://www.it7090.com";
    [FWLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
}

/**
 *  视频
 */
- (void)example07
{
    // 设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [FWLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    // 使用默认配置
    FWLaunchVideoAdConfiguration *videoAdconfiguration = [FWLaunchVideoAdConfiguration defaultConfiguration];
    // 广告视频URLString/或本地视频名(请带上后缀)
    videoAdconfiguration.videoNameOrURLString = @"video0.mp4";
    // 广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    videoAdconfiguration.openModel = @"http://www.it7090.com";
    [FWLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguration delegate:self];
}

@end
