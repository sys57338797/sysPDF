//
//  AppDelegate+InterfaceOrientation.m
//  SysPDF
//
//  Created by mutouren on 4/8/16.
//  Copyright © 2016 suyushen. All rights reserved.
//  未完成

#import "AppDelegate+InterfaceOrientation.h"
#import "NSNotificationCenter+Extra.h"
#import <objc/runtime.h>


void *currentOrientationMaskKey = nil;
void *lastOrientationMaskKey = nil;

NSString *const KInterfaceOrientationNotification       = @"KInterfaceOrientationNotification";

@interface AppDelegate ()

@property (nonatomic, assign) UIInterfaceOrientationMask lastOrientationMask;           //上一次的屏幕方向
@property (nonatomic, assign) UIInterfaceOrientationMask currentOrientationMask;        //当前的屏幕方向

@end

@implementation AppDelegate (InterfaceOrientation)

- (void)setCurrentOrientationMask:(UIInterfaceOrientationMask)currentOrientationMask
{
    objc_setAssociatedObject(self, &currentOrientationMaskKey, [NSNumber numberWithInteger:currentOrientationMask], OBJC_ASSOCIATION_ASSIGN);
}

- (UIInterfaceOrientationMask)currentOrientationMask
{
    NSNumber *ber = objc_getAssociatedObject(self, &currentOrientationMaskKey);
    return [ber integerValue];
}

- (void)setLastOrientationMask:(UIInterfaceOrientationMask)lastOrientationMask
{
    objc_setAssociatedObject(self, &lastOrientationMaskKey, [NSNumber numberWithInteger:lastOrientationMask], OBJC_ASSOCIATION_ASSIGN);
}

- (UIInterfaceOrientationMask)lastOrientationMask
{
    return [objc_getAssociatedObject(self, &lastOrientationMaskKey) integerValue];
}

- (void)setupInterfaceOrientation
{
    self.currentOrientationMask = UIInterfaceOrientationMaskPortrait;
    self.lastOrientationMask = self.currentOrientationMask;
    [NSNotificationCenter addObserverExt:self selector:@selector(updateInterfaceOrientation:) msgName:KInterfaceOrientationNotification object:nil];
}

- (void)updateInterfaceOrientation:(NSNotification*)notification
{
    if (notification.userInfo) {
        UIInterfaceOrientationMask mask = [[notification.userInfo objectForKey:@"orientation"] integerValue];
        [self setCurrentOrientationMask:mask];
        [self deviceSetOrientation:self.currentOrientationMask];
    }
}

- (void)deviceSetOrientation:(UIInterfaceOrientationMask)mask
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = mask;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)nowWindow {
//    
//    return self.currentOrientationMask;
//}

@end
