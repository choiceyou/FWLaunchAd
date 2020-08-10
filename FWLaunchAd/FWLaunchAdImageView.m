//
//  FWLaunchAdImageView.m
//  FWLaunchAd
//
//  Created by xfg on 2018/9/17.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWLaunchAdImageView.h"
#import "FWLaunchAdImageManager.h"

@implementation FWLaunchAdImageView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.frame = [UIScreen mainScreen].bounds;
        self.layer.masksToBounds = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)tap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    if(self.click) self.click(point);
}


- (void)fw_setImageWithURL:(nonnull NSURL *)url
{
    [self fw_setImageWithURL:url placeholderImage:nil];
}

- (void)fw_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder
{
    [self fw_setImageWithURL:url placeholderImage:placeholder options:FWLaunchAdImageDefault];
}

- (void)fw_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(FWLaunchAdImageOptions)options
{
    [self fw_setImageWithURL:url placeholderImage:placeholder options:options completed:nil];
}

- (void)fw_setImageWithURL:(nonnull NSURL *)url completed:(nullable FWExternalCompletionBlock)completedBlock
{
    [self fw_setImageWithURL:url placeholderImage:nil completed:completedBlock];
}

- (void)fw_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable FWExternalCompletionBlock)completedBlock
{
    [self fw_setImageWithURL:url placeholderImage:placeholder options:FWLaunchAdImageDefault completed:completedBlock];
}

- (void)fw_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(FWLaunchAdImageOptions)options completed:(nullable FWExternalCompletionBlock)completedBlock
{
    [self fw_setImageWithURL:url placeholderImage:placeholder dynamicAdPlayType:FWLaunchDynamicAdPlayDefault options:options GIFImageCycleOnceFinish:nil completed:completedBlock];
}

- (void)fw_setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder dynamicAdPlayType:(FWLaunchDynamicAdPlayType)dynamicAdPlayType options:(FWLaunchAdImageOptions)options GIFImageCycleOnceFinish:(void(^_Nullable)(void))cycleOnceFinishBlock completed:(nullable FWExternalCompletionBlock)completedBlock
{
    if(placeholder) self.image = placeholder;
    if(!url) return;
    AdWeakify(self)
    [[FWLaunchAdImageManager sharedManager] loadImageWithURL:url options:options progress:nil completed:^(UIImage * _Nullable image,  NSData *_Nullable imageData, NSError * _Nullable error, NSURL * _Nullable imageURL) {
        
        AdStrongify(self)
        if(!error)
        {
            if(FWIsGIFTypeWithData(imageData))
            {
                self.image = nil;
                self.animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
                self.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
                    AdStrongify(self)
                    if(dynamicAdPlayType != FWLaunchDynamicAdPlayDefault)
                    {
                        [self stopAnimating];
                        ADNSLog(@"GIF不循环,播放完成");
                        if(cycleOnceFinishBlock) cycleOnceFinishBlock();
                    }
                };
            }
            else
            {
                self.image = image;
                self.animatedImage = nil;
            }
        }
        if(completedBlock) completedBlock(image,imageData,error,imageURL);
    }];
}

@end
