//
//  AppDelegate+AsoectsCenter.m
//  BaseMVVM
//
//  Created by suyushen on 15/8/14.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//

#import "AppDelegate+AsoectsCenter.h"
#import <Aspects.h>
#import "ControllerConfigDelegate.h"


@implementation AppDelegate (AsoectsCenter)

+ (void)setupController
{
    [UIViewController aspect_hookSelector:@selector(viewWillAppear:)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo) {
                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                       if ([[aspectInfo instance] isKindOfClass:[UIViewController class]]) {
                                           UIViewController *ctrl = (UIViewController*)[aspectInfo instance];
                                           if ([ctrl conformsToProtocol:@protocol(ControllerConfigDelegate)]) {
                                               if ([ctrl respondsToSelector:@selector(loadNotification)]) {
                                                   [ctrl performSelector:@selector(loadNotification)];
                                               }
                                           }
                                       }
                                   });
                               } error:NULL];
    
    [UIViewController aspect_hookSelector:@selector(viewWillDisappear:)
                              withOptions:AspectPositionInstead
                               usingBlock:^(id<AspectInfo> aspectInfo) {
                                   id sender = [aspectInfo instance];
                                   if ([sender isKindOfClass:[UIViewController class]]) {
                                       UIViewController *ctrl = (UIViewController*)sender;
                                       if ([ctrl conformsToProtocol:@protocol(ControllerConfigDelegate)]) {
                                           if ([ctrl respondsToSelector:@selector(unLoadNotification)]) {
                                               [ctrl performSelector:@selector(unLoadNotification)];
                                           }
                                       }
                                   }
                               } error:NULL];
    
    [UIViewController aspect_hookSelector:@selector(viewDidLoad)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo) {
                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                       if ([[aspectInfo instance] isKindOfClass:[UIViewController class]]) {
                                           UIViewController *ctrl = (UIViewController*)[aspectInfo instance];
                                           if ([ctrl conformsToProtocol:@protocol(ControllerConfigDelegate)]) {
                                               
                                               if ([ctrl respondsToSelector:@selector(loadData)]) {
                                                   [ctrl performSelector:@selector(loadData)];
                                               }
                                           }
                                       }
                                   });
                               } error:NULL];
    
    [UIViewController aspect_hookSelector:@selector(loadView)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo) {
                                   if ([[aspectInfo instance] isKindOfClass:[UIViewController class]]) {
                                       UIViewController *ctrl = (UIViewController*)[aspectInfo instance];
                                       if ([ctrl conformsToProtocol:@protocol(ControllerConfigDelegate)]) {
                                           
                                           if ([ctrl respondsToSelector:@selector(loadUI)]) {
                                               [ctrl performSelector:@selector(loadUI)];
                                           }
                                           
                                       }
                                       
                                   }
                                   
//                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//                                       
//                                   });
                               } error:NULL];
}

@end
