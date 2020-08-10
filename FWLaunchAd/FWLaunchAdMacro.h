//
//  FWLaunchAdMacro.h
//  FWLaunchAd
//
//  Created by xfg on 2018/9/17.
//  Copyright © 2018年 xfg. All rights reserved.
//  宏定义

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 状态栏、导航栏
#define kADStatusBarHeight          ([UIApplication sharedApplication].statusBarFrame.size.height)
#define kADNavBarHeight             44.0
#define kADStatusAndNavBarHeight    (kADStatusBarHeight + kADNavBarHeight)


#define kADScreenWidth              [[UIScreen mainScreen] bounds].size.width
#define kADScreenHeight             [[UIScreen mainScreen] bounds].size.height


// weakself strongself
#define AdWeakify(o)                __weak   typeof(self) fwwo = o;
#define AdStrongify(o)              __strong typeof(self) o = fwwo;


// 日志输出宏定义
#ifdef DEBUG
// 调试状态
#define ADNSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
// 发布状态
#define ADNSLog(...)
#endif


#define DISPATCH_SOURCE_CANCEL_SAFE(time) if(time)\
{\
dispatch_source_cancel(time);\
time = nil;\
}

#define REMOVE_FROM_SUPERVIEW_SAFE(view) if(view)\
{\
[view removeFromSuperview];\
view = nil;\
}

#define AdIsVideoTypeWithPath(path)\
({\
BOOL result = NO;\
if([path hasSuffix:@".mp4"])  result =  YES;\
(result);\
})

#define FWDataWithFileName(name)\
({\
NSData *data = nil;\
NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];\
if([[NSFileManager defaultManager] fileExistsAtPath:path]){\
data = [NSData dataWithContentsOfFile:path];\
}\
(data);\
})

#define FWIsGIFTypeWithData(data)\
({\
BOOL result = NO;\
if(!data) result = NO;\
uint8_t c;\
[data getBytes:&c length:1];\
if(c == 0x47) result = YES;\
(result);\
})



#define AdIsURLString(string)  ([string hasPrefix:@"https://"] || [string hasPrefix:@"http://"]) ? YES:NO
#define AdStringContainsSubString(string,subString)  ([string rangeOfString:subString].location == NSNotFound) ? NO:YES


UIKIT_EXTERN NSString *const FWCacheImageUrlStringKey;
UIKIT_EXTERN NSString *const FWCacheVideoUrlStringKey;

UIKIT_EXTERN NSString *const FWLaunchAdWaitDataDurationArriveNotification;
UIKIT_EXTERN NSString *const FWLaunchAdDetailPageWillShowNotification;
UIKIT_EXTERN NSString *const FWLaunchAdDetailPageShowFinishNotification;
/** dynamicAdPlayType != FWLaunchDynamicAdPlayDefault(GIF不循环)时, GIF动图播放完成通知 */
UIKIT_EXTERN NSString *const FWLaunchAdGIFImageCycleOnceFinishNotification;
/** dynamicAdPlayType != FWLaunchDynamicAdPlayDefault(视频不循环时) ,video播放完成通知 */
UIKIT_EXTERN NSString *const FWLaunchAdVideoCycleOnceFinishNotification;
/** 视频播放失败通知 */
UIKIT_EXTERN NSString *const FWLaunchAdVideoPlayFailedNotification;
UIKIT_EXTERN BOOL FWLaunchAdPrefersHomeIndicatorAutoHidden;
