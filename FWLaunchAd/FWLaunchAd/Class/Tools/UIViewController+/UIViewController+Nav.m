//
//  UIViewController+Nav.m
//  FWLaunchAd
//
//  Created by xfg on 2018/9/14.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "UIViewController+Nav.h"

@implementation UIViewController (Nav)

- (UINavigationController*)myNavigationController
{
    UINavigationController* nav = nil;
    if ([self isKindOfClass:[UINavigationController class]])
    {
        nav = (id)self;
    }
    else
    {
        if ([self isKindOfClass:[UITabBarController class]])
        {
            nav = ((UITabBarController*)self).selectedViewController.myNavigationController;
        }
        else
        {
            nav = self.navigationController;
        }
    }
    return nav;
}

@end
