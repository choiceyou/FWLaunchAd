//
//  LaunchAdModel.m
//  FWLaunchAd
//
//  Created by xfg on 2018/9/14.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "LaunchAdModel.h"

@implementation LaunchAdModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
        self.content = dict[@"content"];
        self.openUrl = dict[@"openUrl"];
        self.duration = [dict[@"duration"] integerValue];
        self.contentSize = dict[@"contentSize"];
    }
    return self;
}

- (CGFloat)width
{
    return [[[self.contentSize componentsSeparatedByString:@"*"] firstObject] floatValue];
}

- (CGFloat)height
{
    return [[[self.contentSize componentsSeparatedByString:@"*"] lastObject] floatValue];
}

@end
