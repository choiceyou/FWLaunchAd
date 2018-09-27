//
//  FWLaunchAdDownloader.h
//  FWLaunchAd
//
//  Created by xfg on 2018/9/26.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^FWLaunchAdDownloadProgressBlock)(unsigned long long total, unsigned long long current);

typedef void(^FWLaunchAdDownloadImageCompletedBlock)(UIImage *_Nullable image, NSData * _Nullable data, NSError * _Nullable error);

typedef void(^FWLaunchAdDownloadVideoCompletedBlock)(NSURL * _Nullable location, NSError * _Nullable error);

typedef void(^FWLaunchAdBatchDownLoadAndCacheCompletedBlock) (NSArray * _Nonnull completedArray);


#pragma mark - FWLaunchAdDownload

@protocol FWLaunchAdDownloadDelegate <NSObject>

- (void)downloadFinishWithURL:(nonnull NSURL *)url;

@end


@interface FWLaunchAdDownload : NSObject

@property (assign, nonatomic ,nonnull) id<FWLaunchAdDownloadDelegate> delegate;

@end


@interface FWLaunchAdImageDownload : FWLaunchAdDownload

@end


@interface FWLaunchAdVideoDownload : FWLaunchAdDownload

@end


#pragma mark - FWLaunchAdDownloader

@interface FWLaunchAdDownloader : NSObject

+ (nonnull instancetype )sharedDownloader;

- (void)downloadImageWithURL:(nonnull NSURL *)url progress:(nullable FWLaunchAdDownloadProgressBlock)progressBlock completed:(nullable FWLaunchAdDownloadImageCompletedBlock)completedBlock;

- (void)downLoadImageAndCacheWithURLArray:(nonnull NSArray <NSURL *> *)urlArray;
- (void)downLoadImageAndCacheWithURLArray:(nonnull NSArray <NSURL *> *)urlArray completed:(nullable FWLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock;

- (void)downloadVideoWithURL:(nonnull NSURL *)url progress:(nullable FWLaunchAdDownloadProgressBlock)progressBlock completed:(nullable FWLaunchAdDownloadVideoCompletedBlock)completedBlock;

- (void)downLoadVideoAndCacheWithURLArray:(nonnull NSArray <NSURL *> *)urlArray;
- (void)downLoadVideoAndCacheWithURLArray:(nonnull NSArray <NSURL *> *)urlArray completed:(nullable FWLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock;

@end
