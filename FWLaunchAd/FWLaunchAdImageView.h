//
//  FWLaunchAdImageView.h
//  FWLaunchAd
//
//  Created by xfg on 2018/9/17.
//  Copyright © 2018年 xfg. All rights reserved.
//  图片类型的启动广告

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FWLaunchAdImageManager.h"
#import "FWLaunchAdConfiguration.h"

#if __has_include(<FLAnimatedImage/FLAnimatedImage.h>)
#import <FLAnimatedImage/FLAnimatedImage.h>
#else
#import "FLAnimatedImage.h"
#endif

#if __has_include(<FLAnimatedImage/FLAnimatedImageView.h>)
#import <FLAnimatedImage/FLAnimatedImageView.h>
#else
#import "FLAnimatedImageView.h"
#endif


@interface FWLaunchAdImageView : FLAnimatedImageView

@property (nonatomic, copy) void(^click)(CGPoint point);

/**
 设置url图片

 @param url 图片url
 */
- (void)fw_setImageWithURL:(nonnull NSURL *)url;

/**
 设置url图片
 
 @param url 图片url
 @param placeholder 占位图
 */
- (void)fw_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder;

/**
 设置url图片
 
 @param url 图片url
 @param placeholder 占位图
 @param options FWLaunchAdImageOptions
 */
- (void)fw_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(FWLaunchAdImageOptions)options;

/**
 设置url图片
 
 @param url 图片url
 @param completedBlock FWExternalCompletionBlock
 */
- (void)fw_setImageWithURL:(nonnull NSURL *)url completed:(nullable FWExternalCompletionBlock)completedBlock;

/**
 设置url图片
 
 @param url 图片url
 @param placeholder 占位图
 @param completedBlock FWExternalCompletionBlock
 */
- (void)fw_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable FWExternalCompletionBlock)completedBlock;

/**
 设置url图片
 
 @param url 图片url
 @param placeholder 占位图
 @param options FWLaunchAdImageOptions
 @param completedBlock FWExternalCompletionBlock
 */
- (void)fw_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(FWLaunchAdImageOptions)options completed:(nullable FWExternalCompletionBlock)completedBlock;

/**
 设置url图片

 @param url 图片url
 @param placeholder 占位图
 @param dynamicAdPlayType 动态类型的启动广告（gif图片、视频）：播放策略
 @param options FWLaunchAdImageOptions
 @param cycleOnceFinishBlock gif播放完回调(GIFImageCycleOnce = YES 有效)
 @param completedBlock FWExternalCompletionBlock
 */
- (void)fw_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder dynamicAdPlayType:(FWLaunchDynamicAdPlayType)dynamicAdPlayType options:(FWLaunchAdImageOptions)options GIFImageCycleOnceFinish:(void(^_Nullable)(void))cycleOnceFinishBlock completed:(nullable FWExternalCompletionBlock)completedBlock;

@end
