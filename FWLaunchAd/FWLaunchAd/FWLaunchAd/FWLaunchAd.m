//
//  FWLaunchAd.m
//  FWLaunchAd
//
//  Created by xfg on 2018/9/14.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWLaunchAd.h"
#import "FWLaunchAdCloseBtn.h"
#import "FWLaunchAdVideoView.h"
#import "FWLaunchAdController.h"
#import "FWLaunchAdImageView.h"
#import "FWLaunchAdVideoView.h"
#import "FWLaunchAdCache.h"

/**
 广告类型
 
 - FWLaunchAdTypeImage: 图片类型
 - FWLaunchAdTypeVideo: 视频类型
 */
typedef NS_ENUM(NSInteger, FWLaunchAdType)
{
    FWLaunchAdTypeImage = 0,
    FWLaunchAdTypeVideo
};

static NSInteger defaultWaitDataDuration = 3;
static  SourceType _sourceType = SourceTypeLaunchImage;

@interface FWLaunchAd ()

@property (nonatomic, assign) FWLaunchAdType launchAdType;
@property (nonatomic, assign) NSInteger waitDataDuration;
@property (nonatomic, strong) FWLaunchImageAdConfiguration *imageAdConfiguration;
@property (nonatomic, strong) FWLaunchVideoAdConfiguration *videoAdConfiguration;
@property (nonatomic, strong) FWLaunchAdCloseBtn *skipButton;
@property (nonatomic, strong) FWLaunchAdVideoView *adVideoView;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, copy) dispatch_source_t waitDataTimer;
@property (nonatomic, copy) dispatch_source_t skipTimer;
@property (nonatomic, assign) BOOL detailPageShowing;
@property (nonatomic, assign) CGPoint clickPoint;

@end


@implementation FWLaunchAd

#pragma mark - ----------------------- 类方法设置 -----------------------

+ (void)setLaunchSourceType:(SourceType)sourceType
{
    _sourceType = sourceType;
}

+ (void)setWaitDataDuration:(NSInteger )waitDataDuration
{
    FWLaunchAd *launchAd = [FWLaunchAd shareInstance];
    launchAd.waitDataDuration = waitDataDuration;
}

+ (FWLaunchAd *)imageAdWithImageAdConfiguration:(FWLaunchImageAdConfiguration *)imageAdconfiguration
{
    return [FWLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:nil];
}

+ (FWLaunchAd *)imageAdWithImageAdConfiguration:(FWLaunchImageAdConfiguration *)imageAdconfiguration delegate:(id)delegate
{
    FWLaunchAd *launchAd = [FWLaunchAd shareInstance];
    if(delegate) launchAd.delegate = delegate;
    launchAd.imageAdConfiguration = imageAdconfiguration;
    return launchAd;
}

+ (FWLaunchAd *)videoAdWithVideoAdConfiguration:(FWLaunchVideoAdConfiguration *)videoAdconfiguration
{
    return [FWLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguration delegate:nil];
}

+ (FWLaunchAd *)videoAdWithVideoAdConfiguration:(FWLaunchVideoAdConfiguration *)videoAdconfiguration delegate:(nullable id)delegate
{
    FWLaunchAd *launchAd = [FWLaunchAd shareInstance];
    if(delegate) launchAd.delegate = delegate;
    launchAd.videoAdConfiguration = videoAdconfiguration;
    return launchAd;
}

+ (void)downLoadImageAndCacheWithURLArray:(NSArray <NSURL *> *)urlArray
{
    [self downLoadImageAndCacheWithURLArray:urlArray completed:nil];
}

+ (void)downLoadImageAndCacheWithURLArray:(NSArray <NSURL *> *)urlArray completed:(nullable FWLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock
{
    if(urlArray.count==0) return;
    [[FWLaunchAdDownloader sharedDownloader] downLoadImageAndCacheWithURLArray:urlArray completed:completedBlock];
}

+ (void)downLoadVideoAndCacheWithURLArray:(NSArray <NSURL *> *)urlArray
{
    [self downLoadVideoAndCacheWithURLArray:urlArray completed:nil];
}

+ (void)downLoadVideoAndCacheWithURLArray:(NSArray <NSURL *> *)urlArray completed:(nullable FWLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock
{
    if(urlArray.count==0) return;
    [[FWLaunchAdDownloader sharedDownloader] downLoadVideoAndCacheWithURLArray:urlArray completed:completedBlock];
}

+ (void)removeAndAnimated:(BOOL)animated
{
    [[FWLaunchAd shareInstance] removeAndAnimated:animated];
}

+ (BOOL)checkImageInCacheWithURL:(NSURL *)url
{
    return [FWLaunchAdCache checkImageInCacheWithURL:url];
}

+ (BOOL)checkVideoInCacheWithURL:(NSURL *)url
{
    return [FWLaunchAdCache checkVideoInCacheWithURL:url];
}

+ (void)clearDiskCache
{
    [FWLaunchAdCache clearDiskCache];
}

+ (void)clearDiskCacheWithImageUrlArray:(NSArray<NSURL *> *)imageUrlArray
{
    [FWLaunchAdCache clearDiskCacheWithImageUrlArray:imageUrlArray];
}

+ (void)clearDiskCacheExceptImageUrlArray:(NSArray<NSURL *> *)exceptImageUrlArray
{
    [FWLaunchAdCache clearDiskCacheExceptImageUrlArray:exceptImageUrlArray];
}

+ (void)clearDiskCacheWithVideoUrlArray:(NSArray<NSURL *> *)videoUrlArray
{
    [FWLaunchAdCache clearDiskCacheWithVideoUrlArray:videoUrlArray];
}

+ (void)clearDiskCacheExceptVideoUrlArray:(NSArray<NSURL *> *)exceptVideoUrlArray
{
    [FWLaunchAdCache clearDiskCacheExceptVideoUrlArray:exceptVideoUrlArray];
}

+ (float)diskCacheSize
{
    return [FWLaunchAdCache diskCacheSize];
}

+ (NSString *)fwLaunchAdCachePath
{
    return [FWLaunchAdCache fwLaunchAdCachePath];
}

+ (NSString *)cacheImageURLString
{
    return [FWLaunchAdCache getCacheImageUrl];
}

+ (NSString *)cacheVideoURLString
{
    return [FWLaunchAdCache getCacheVideoUrl];
}


#pragma mark - ----------------------- private -----------------------

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (FWLaunchAd *)shareInstance
{
    static FWLaunchAd *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[FWLaunchAd alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupLaunchAd];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self setupLaunchAdEnterForeground];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self removeOnly];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:FWLaunchAdDetailPageWillShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            self.detailPageShowing = YES;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:FWLaunchAdDetailPageShowFinishNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            self.detailPageShowing = NO;
        }];
    }
    return self;
}

- (void)setupLaunchAdEnterForeground
{
    switch (_launchAdType) {
        case FWLaunchAdTypeImage:
        {
            if(!_imageAdConfiguration.showEnterForeground || _detailPageShowing) return;
            [self setupLaunchAd];
            [self setupImageAdForConfiguration:_imageAdConfiguration];
        }
            break;
        case FWLaunchAdTypeVideo:
        {
            if(!_videoAdConfiguration.showEnterForeground || _detailPageShowing) return;
            [self setupLaunchAd];
            [self setupVideoAdForConfiguration:_videoAdConfiguration];
        }
            break;
        default:
            break;
    }
}

- (void)setupLaunchAd
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [[FWLaunchAdController alloc] init];
    window.rootViewController.view.backgroundColor = [UIColor clearColor];
    window.rootViewController.view.userInteractionEnabled = NO;
    window.windowLevel = UIWindowLevelStatusBar + 1;
    window.hidden = NO;
    window.alpha = 1;
    _window = window;
    // 添加launchImageView
    [_window addSubview:[[FWLaunchImageView alloc] initWithSourceType:_sourceType]];
}

- (void)setupImageAdForConfiguration:(FWLaunchImageAdConfiguration *)configuration
{
    if(_window == nil)
    {
        return;
    }
    
    [self removeSubViewsExceptLaunchAdImageView];
    FWLaunchAdImageView *adImageView = [[FWLaunchAdImageView alloc] init];
    [_window addSubview:adImageView];
    
    // frame
    if(configuration.frame.size.width>0 && configuration.frame.size.height>0)
    {
        adImageView.frame = configuration.frame;
    }
    
    if(configuration.contentMode)
    {
        adImageView.contentMode = configuration.contentMode;
    }
    
    // webImage
    if(configuration.imageNameOrURLString.length && AdIsURLString(configuration.imageNameOrURLString))
    {
        // 自设图片
        if ([self.delegate respondsToSelector:@selector(fwLaunchAd:launchAdImageView:URL:)])
        {
            [self.delegate fwLaunchAd:self launchAdImageView:adImageView URL:[NSURL URLWithString:configuration.imageNameOrURLString]];
        }
        else
        {
            if(!configuration.imageOption)
            {
                configuration.imageOption = FWLaunchAdImageDefault;
            }
            
            AdWeakify(self)
            [adImageView fw_setImageWithURL:[NSURL URLWithString:configuration.imageNameOrURLString] placeholderImage:nil dynamicAdPlayType:configuration.dynamicAdPlayType options:configuration.imageOption GIFImageCycleOnceFinish:^{
                // GIF不循环,播放完成
                [[NSNotificationCenter defaultCenter] postNotificationName:FWLaunchAdGIFImageCycleOnceFinishNotification object:nil userInfo:@{@"imageNameOrURLString":configuration.imageNameOrURLString}];
                
            } completed:^(UIImage *image,NSData *imageData,NSError *error,NSURL *url){
                
                if(!error)
                {
                    AdStrongify(self)
                    if ([self.delegate respondsToSelector:@selector(fwLaunchAd:imageDownLoadFinish:imageData:)])
                    {
                        [self.delegate fwLaunchAd:self imageDownLoadFinish:image imageData:imageData];
                    }
                }
            }];
            
            if(configuration.imageOption == FWLaunchAdImageCacheInBackground)
            {
                // 缓存中未有
                if(![FWLaunchAdCache checkImageInCacheWithURL:[NSURL URLWithString:configuration.imageNameOrURLString]])
                {
                    [self removeAndAnimateDefault];
                    // 完成显示
                    return;
                }
            }
        }
    }
    else
    {
        if(configuration.imageNameOrURLString.length)
        {
            NSData *data = FWDataWithFileName(configuration.imageNameOrURLString);
            if(FWIsGIFTypeWithData(data))
            {
                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
                adImageView.animatedImage = image;
                adImageView.image = nil;
                __weak typeof(adImageView) w_adImageView = adImageView;
                adImageView.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
                    if(configuration.dynamicAdPlayType != FWLaunchDynamicAdPlayDefault)
                    {
                        [w_adImageView stopAnimating];
                        ADNSLog(@"GIF不循环,播放完成");
                        [[NSNotificationCenter defaultCenter] postNotificationName:FWLaunchAdGIFImageCycleOnceFinishNotification object:@{@"imageNameOrURLString":configuration.imageNameOrURLString}];
                        
                        if (configuration.dynamicAdPlayType == FWLaunchDynamicAdPlayCycleOnceFinished)
                        {
                            [self removeAndAnimate];
                        }
                    }
                };
            }
            else
            {
                adImageView.animatedImage = nil;
                adImageView.image = [UIImage imageWithData:data];
            }
        }
        else
        {
            ADNSLog(@"未设置广告图片");
        }
    }
    // skipButton
    [self addSkipButtonForConfiguration:configuration];
    [self startSkipDispathTimer];
    // customView
    if(configuration.subViews.count>0)
    {
        [self addSubViews:configuration.subViews];
    }
    
    AdWeakify(self)
    adImageView.click = ^(CGPoint point) {
        AdStrongify(self)
        [self clickAndPoint:point];
    };
}

- (void)addSkipButtonForConfiguration:(FWLaunchAdConfiguration *)configuration
{
    if(!configuration.duration)
    {
        configuration.duration = adShowDurationDefault;
    }
    if(!configuration.skipButtonType)
    {
        configuration.skipButtonType = AdSkipTypeTimeText;
    }
    
    if(configuration.customSkipView)
    {
        [_window addSubview:configuration.customSkipView];
    }
    else
    {
        if(_skipButton == nil)
        {
            _skipButton = [[FWLaunchAdCloseBtn alloc] initWithSkipType:configuration.skipButtonType];
            _skipButton.hidden = YES;
            [_skipButton addTarget:self action:@selector(skipButtonClick) forControlEvents:UIControlEventTouchUpInside];
        }
        [_window addSubview:_skipButton];
        [_skipButton setTitleWithSkipType:configuration.skipButtonType duration:configuration.duration];
    }
}

- (void)setupVideoAdForConfiguration:(FWLaunchVideoAdConfiguration *)configuration
{
    if(_window ==nil)
    {
        return;
    }
    
    [self removeSubViewsExceptLaunchAdImageView];
    if(!_adVideoView)
    {
        _adVideoView = [[FWLaunchAdVideoView alloc] init];
    }
    [_window addSubview:_adVideoView];
    
    // frame
    if(configuration.frame.size.width>0 && configuration.frame.size.height>0)
    {
        _adVideoView.frame = configuration.frame;
    }
    if(configuration.videoGravity)
    {
        _adVideoView.videoGravity = configuration.videoGravity;
    }
    _adVideoView.dynamicAdPlayType = configuration.dynamicAdPlayType;
    
    if(configuration.dynamicAdPlayType != FWLaunchDynamicAdPlayDefault)
    {
        [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            ADNSLog(@"video不循环,播放完成");
            [[NSNotificationCenter defaultCenter] postNotificationName:FWLaunchAdVideoCycleOnceFinishNotification object:nil userInfo:@{@"videoNameOrURLString":configuration.videoNameOrURLString}];
            
            if (configuration.dynamicAdPlayType == FWLaunchDynamicAdPlayCycleOnceFinished)
            {
                [self removeAndAnimate];
            }
        }];
    }
    
    // video 数据源
    if(configuration.videoNameOrURLString.length && AdIsURLString(configuration.videoNameOrURLString))
    {
        [FWLaunchAdCache async_saveVideoUrl:configuration.videoNameOrURLString];
        NSURL *pathURL = [FWLaunchAdCache getCacheVideoWithURL:[NSURL URLWithString:configuration.videoNameOrURLString]];
        if(pathURL)
        {
            if ([self.delegate respondsToSelector:@selector(fwLaunchAd:videoDownLoadFinish:)])
            {
                [self.delegate fwLaunchAd:self videoDownLoadFinish:pathURL];
            }
            _adVideoView.contentURL = pathURL;
            _adVideoView.muted = configuration.muted;
            [_adVideoView.videoPlayer.player play];
        }
        else
        {
            AdWeakify(self)
            [[FWLaunchAdDownloader sharedDownloader] downloadVideoWithURL:[NSURL URLWithString:configuration.videoNameOrURLString] progress:^(unsigned long long total, unsigned long long current) {
                AdStrongify(self)
                if ([self.delegate respondsToSelector:@selector(fwLaunchAd:videoDownLoadProgress:total:current:)])
                {
                    [self.delegate fwLaunchAd:self videoDownLoadProgress:current/(float)total total:total current:current];
                }
            } completed:^(NSURL * _Nullable location, NSError * _Nullable error) {
                if(!error)
                {
                    AdStrongify(self)
                    if ([self.delegate respondsToSelector:@selector(fwLaunchAd:videoDownLoadFinish:)])
                    {
                        [self.delegate fwLaunchAd:self videoDownLoadFinish:location];
                    }
                }
            }];
            // 视频缓存,提前显示完成
            [self removeAndAnimateDefault]; return;
        }
    }
    else
    {
        if(configuration.videoNameOrURLString.length)
        {
            NSURL *pathURL = nil;
            NSURL *cachePathURL = [[NSURL alloc] initFileURLWithPath:[FWLaunchAdCache videoPathWithFileName:configuration.videoNameOrURLString]];
            // 若本地视频未在沙盒缓存文件夹中
            if (![FWLaunchAdCache checkVideoInCacheWithFileName:configuration.videoNameOrURLString])
            {
                // 如果不在沙盒文件夹中则将其复制一份到沙盒缓存文件夹中/下次直接取缓存文件夹文件,加快文件查找速度
                NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:configuration.videoNameOrURLString withExtension:nil];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[NSFileManager defaultManager] copyItemAtURL:bundleURL toURL:cachePathURL error:nil];
                });
                pathURL = bundleURL;
            }
            else
            {
                pathURL = cachePathURL;
            }
            
            if(pathURL)
            {
                if ([self.delegate respondsToSelector:@selector(fwLaunchAd:videoDownLoadFinish:)])
                {
                    [self.delegate fwLaunchAd:self videoDownLoadFinish:pathURL];
                }
                _adVideoView.contentURL = pathURL;
                _adVideoView.muted = configuration.muted;
                [_adVideoView.videoPlayer.player play];
            }
            else
            {
                ADNSLog(@"Error:广告视频未找到,请检查名称是否有误!");
            }
        }
        else
        {
            ADNSLog(@"未设置广告视频");
        }
    }
    // skipButton
    [self addSkipButtonForConfiguration:configuration];
    [self startSkipDispathTimer];
    // customView
    if(configuration.subViews.count>0) [self addSubViews:configuration.subViews];
    AdWeakify(self)
    _adVideoView.click = ^(CGPoint point) {
        AdStrongify(self)
        [self clickAndPoint:point];
    };
}


#pragma mark - ----------------------- add subViews -----------------------

- (void)addSubViews:(NSArray *)subViews
{
    [subViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [self.window addSubview:view];
    }];
}


#pragma mark - ----------------------- Action -----------------------

- (void)skipButtonClick
{
    [self removeAndAnimated:YES];
}

- (void)removeAndAnimated:(BOOL)animated
{
    if(animated)
    {
        [self removeAndAnimate];
    }
    else
    {
        [self remove];
    }
}

- (void)removeOnly
{
    DISPATCH_SOURCE_CANCEL_SAFE(_waitDataTimer)
    DISPATCH_SOURCE_CANCEL_SAFE(_skipTimer)
    REMOVE_FROM_SUPERVIEW_SAFE(_skipButton)
    if(_launchAdType == FWLaunchAdTypeVideo)
    {
        if(_adVideoView)
        {
            [_adVideoView stopVideoPlayer];
            REMOVE_FROM_SUPERVIEW_SAFE(_adVideoView)
        }
    }
    if(_window)
    {
        [_window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            REMOVE_FROM_SUPERVIEW_SAFE(obj)
        }];
        _window.hidden = YES;
        _window = nil;
    }
}

- (void)clickAndPoint:(CGPoint)point
{
    self.clickPoint = point;
    FWLaunchAdConfiguration *configuration = [self commonConfiguration];
    if ([self.delegate respondsToSelector:@selector(fwLaunchAd:clickAndOpenModel:clickPoint:)])
    {
        [self.delegate fwLaunchAd:self clickAndOpenModel:configuration.openModel clickPoint:point];
        [self removeAndAnimateDefault];
    }
}

- (void)removeAndAnimateDefault
{
    FWLaunchAdConfiguration *configuration = [self commonConfiguration];
    CGFloat duration = showFinishAnimateTimeDefault;
    if(configuration.showFinishAnimateTime>0) duration = configuration.showFinishAnimateTime;
    [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionNone animations:^{
        self.window.alpha = 0;
    } completion:^(BOOL finished) {
        [self remove];
    }];
}

- (void)removeSubViewsExceptLaunchAdImageView
{
    [_window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![obj isKindOfClass:[FWLaunchImageView class]])
        {
            REMOVE_FROM_SUPERVIEW_SAFE(obj)
        }
    }];
}

- (void)remove
{
    [self removeOnly];
    
    if ([self.delegate respondsToSelector:@selector(fwLaunchAdShowFinish:)])
    {
        [self.delegate fwLaunchAdShowFinish:self];
    }
}

- (void)removeAndAnimate
{
    FWLaunchAdConfiguration *configuration = [self commonConfiguration];
    CGFloat duration = showFinishAnimateTimeDefault;
    if(configuration.showFinishAnimateTime > 0)
    {
        duration = configuration.showFinishAnimateTime;
    }
    switch (configuration.showFinishAnimate) {
        case AdShowCompletedAnimateNone:
        {
            [self remove];
        }
            break;
        case AdShowCompletedAnimateFadein:
        {
            [self removeAndAnimateDefault];
        }
            break;
        case AdShowCompletedAnimateLite:
        {
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.window.transform = CGAffineTransformMakeScale(1.5, 1.5);
                self.window.alpha = 0;
            } completion:^(BOOL finished) {
                [self remove];
            }];
        }
            break;
        case AdShowCompletedAnimateFlipFromLeft:
        {
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                self.window.alpha = 0;
            } completion:^(BOOL finished) {
                [self remove];
            }];
        }
            break;
        case AdShowCompletedAnimateFlipFromBottom:
        {
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
                self.window.alpha = 0;
            } completion:^(BOOL finished) {
                [self remove];
            }];
        }
            break;
        case AdShowCompletedAnimateCurlUp:
        {
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionCurlUp animations:^{
                self.window.alpha = 0;
            } completion:^(BOOL finished) {
                [self remove];
            }];
        }
            break;
        default:{
            [self removeAndAnimateDefault];
        }
            break;
    }
}


#pragma mark - ----------------------- 定时器 -----------------------

- (void)startWaitDataDispathTiemr
{
    __block NSInteger duration = defaultWaitDataDuration;
    if(_waitDataDuration) duration = _waitDataDuration;
    _waitDataTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    NSTimeInterval period = 1.0;
    dispatch_source_set_timer(_waitDataTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_waitDataTimer, ^{
        if(duration==0){
            DISPATCH_SOURCE_CANCEL_SAFE(self.waitDataTimer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:FWLaunchAdWaitDataDurationArriveNotification object:nil];
                [self remove];
                return ;
            });
        }
        duration--;
    });
    dispatch_resume(_waitDataTimer);
}

- (void)startSkipDispathTimer
{
    FWLaunchAdConfiguration *configuration = [self commonConfiguration];
    if (configuration.dynamicAdPlayType == FWLaunchDynamicAdPlayCycleOnceFinished)
    {
        return;
    }
    
    DISPATCH_SOURCE_CANCEL_SAFE(_waitDataTimer);
    if(!configuration.skipButtonType) configuration.skipButtonType = AdSkipTypeTimeText; // 默认
    __block NSInteger duration = adShowDurationDefault; // 默认
    if(configuration.duration)
    {
        duration = configuration.duration;
    }
    if(configuration.skipButtonType == AdSkipTypeRoundProgressTime || configuration.skipButtonType == AdSkipTypeRoundProgressText)
    {
        [_skipButton startRoundDispathTimerWithDuration:duration];
    }
    NSTimeInterval period = 1.0;
    _skipTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_skipTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_skipTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(fwLaunchAd:customSkipView:duration:)])
            {
                [self.delegate fwLaunchAd:self customSkipView:configuration.customSkipView duration:duration];
            }
            if(!configuration.customSkipView)
            {
                [self.skipButton setTitleWithSkipType:configuration.skipButtonType duration:duration];
            }
            if(duration==0)
            {
                DISPATCH_SOURCE_CANCEL_SAFE(self.skipTimer);
                [self removeAndAnimate];
                return ;
            }
            duration--;
        });
    });
    dispatch_resume(_skipTimer);
}


#pragma mark - ----------------------- SET/GET -----------------------

- (FWLaunchAdConfiguration *)commonConfiguration
{
    FWLaunchAdConfiguration *configuration = nil;
    switch (_launchAdType) {
        case FWLaunchAdTypeVideo:
            configuration = _videoAdConfiguration;
            break;
        case FWLaunchAdTypeImage:
            configuration = _imageAdConfiguration;
            break;
        default:
            break;
    }
    return configuration;
}

- (void)setImageAdConfiguration:(FWLaunchImageAdConfiguration *)imageAdConfiguration
{
    _imageAdConfiguration = imageAdConfiguration;
    _launchAdType = FWLaunchAdTypeImage;
    [self setupImageAdForConfiguration:imageAdConfiguration];
}

- (void)setVideoAdConfiguration:(FWLaunchVideoAdConfiguration *)videoAdConfiguration
{
    _videoAdConfiguration = videoAdConfiguration;
    _launchAdType = FWLaunchAdTypeVideo;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CGFLOAT_MIN * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupVideoAdForConfiguration:videoAdConfiguration];
    });
}

- (void)setWaitDataDuration:(NSInteger)waitDataDuration
{
    _waitDataDuration = waitDataDuration;
    // 数据等待
    [self startWaitDataDispathTiemr];
}

@end
