//
//  FWLaunchAdImageManager.m
//  FWLaunchAd
//
//  Created by xfg on 2018/9/17.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWLaunchAdImageManager.h"
#import "FWLaunchAdCache.h"

@interface FWLaunchAdImageManager()

@property(nonatomic, strong) FWLaunchAdDownloader *downloader;

@end


@implementation FWLaunchAdImageManager

+ (nonnull instancetype )sharedManager
{
    static FWLaunchAdImageManager *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[FWLaunchAdImageManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloader = [FWLaunchAdDownloader sharedDownloader];
    }
    return self;
}

- (void)loadImageWithURL:(nullable NSURL *)url options:(FWLaunchAdImageOptions)options progress:(nullable FWLaunchAdDownloadProgressBlock)progressBlock completed:(nullable FWExternalCompletionBlock)completedBlock
{
    if(!options)
    {
        options = FWLaunchAdImageDefault;
    }
    
    if(options & FWLaunchAdImageOnlyLoad)
    {
        [_downloader downloadImageWithURL:url progress:progressBlock completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error) {
            if(completedBlock) completedBlock(image,data,error,url);
        }];
    }
    else if (options & FWLaunchAdImageRefreshCached)
    {
        NSData *imageData = [FWLaunchAdCache getCacheImageDataWithURL:url];
        UIImage *image =  [UIImage imageWithData:imageData];
        if(image && completedBlock) completedBlock(image,imageData,nil,url);
        [_downloader downloadImageWithURL:url progress:progressBlock completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error) {
            if(completedBlock) completedBlock(image,data,error,url);
            [FWLaunchAdCache async_saveImageData:data imageURL:url completed:nil];
        }];
    }
    else if (options & FWLaunchAdImageCacheInBackground)
    {
        NSData *imageData = [FWLaunchAdCache getCacheImageDataWithURL:url];
        UIImage *image =  [UIImage imageWithData:imageData];
        if(image && completedBlock)
        {
            completedBlock(image,imageData,nil,url);
        }
        else
        {
            [_downloader downloadImageWithURL:url progress:progressBlock completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error) {
                [FWLaunchAdCache async_saveImageData:data imageURL:url completed:nil];
            }];
        }
    }
    else
    {
        // default
        NSData *imageData = [FWLaunchAdCache getCacheImageDataWithURL:url];
        UIImage *image =  [UIImage imageWithData:imageData];
        if(image && completedBlock)
        {
            completedBlock(image,imageData,nil,url);
        }
        else
        {
            [_downloader downloadImageWithURL:url progress:progressBlock completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error) {
                if(completedBlock) completedBlock(image,data,error,url);
                [FWLaunchAdCache async_saveImageData:data imageURL:url completed:nil];
            }];
        }
    }
}

@end
