//
//  FWLaunchAdImageManager.h
//  FWLaunchAd
//
//  Created by xfg on 2018/9/17.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FWLaunchAdMacro.h"
#import "FWLaunchAdDownloader.h"

/**
 广告图片策略

 - FWLaunchAdImageDefault: 有缓存,读取缓存,不重新下载,没缓存先下载,并缓存
 - FWLaunchAdImageOnlyLoad: 只下载,不缓存
 - FWLaunchAdImageRefreshCached: 先读缓存,再下载刷新图片和缓存
 - FWLaunchAdImageCacheInBackground: 后台缓存本次不显示,缓存OK后下次再显示(建议使用这种方式)
 */
typedef NS_OPTIONS(NSUInteger, FWLaunchAdImageOptions)
{
    FWLaunchAdImageDefault = 1 << 0,
    FWLaunchAdImageOnlyLoad = 1 << 1,
    FWLaunchAdImageRefreshCached = 1 << 2 ,
    FWLaunchAdImageCacheInBackground = 1 << 3
};

typedef void(^FWExternalCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable imageData, NSError * _Nullable error, NSURL * _Nullable imageURL);


@interface FWLaunchAdImageManager : NSObject

+ (nonnull instancetype )sharedManager;

/**
 下载图片

 @param url 图片URL地址
 @param options 广告图片策略
 @param progressBlock 下载d进度
 @param completedBlock 下载完成回调
 */
- (void)loadImageWithURL:(nullable NSURL *)url options:(FWLaunchAdImageOptions)options progress:(nullable FWLaunchAdDownloadProgressBlock)progressBlock completed:(nullable FWExternalCompletionBlock)completedBlock;

@end
