//
//  NavManager.m
//  NavManager
//
//  Created by suyushen on 14-10-14.
//  Copyright (c) 2014年 suyushen. All rights reserved.
//

#import "NavManager.h"
#import "OrientationNavViewController.h"


@interface NavManager ()

@property (nonatomic, strong) NSMutableArray *showModeArray;
@property (nonatomic, strong) NSMutableArray *navCatrlArray;

@end

@implementation NavManager


-(id)init
{
    self = [super init];
    if (self) {
        self.showModeArray = [NSMutableArray array];
        self.navCatrlArray = [NSMutableArray array];
    }
    return self;
}


//share Instance of ViewManager
+ (NavManager *)shareInstance
{
    static NavManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^ { instance = [[NavManager alloc] init]; });
    return instance;
}

- (void)setRootController:(UIViewController*)controller
{
    UINavigationController *rootNavCtrl = [self BaseNavigationControllerWithViewController:controller];
    [self.navCatrlArray addObject:rootNavCtrl];
    [rootNavCtrl prefersStatusBarHidden];
    [rootNavCtrl performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    [self.showModeArray addObject:[NSNumber numberWithInteger:ControllerShowModeRoot]];
}

- (void)showViewController:(UIViewController*)controller isAnimated:(BOOL)isAnimated
{
    [[self getCurNavigationController] pushViewController:controller animated:isAnimated];
    [self.showModeArray addObject:[NSNumber numberWithInteger:ControllerShowModePush]];
}

- (void)showViewController:(UIViewController*)controller isAnimated:(BOOL)isAnimated showType:(ControllerShowMode)showMode
{
    [self.showModeArray addObject:[NSNumber numberWithInteger:showMode]];
    switch (showMode) {
        case ControllerShowModePush:
        {
            [self showViewController:controller isAnimated:isAnimated];
            break;
        }
        case ControllerShowModeModel:
        {
            UINavigationController *navCtrl = [self BaseNavigationControllerWithViewController:controller];
            [[self getCurNavigationController] presentViewController:navCtrl animated:isAnimated completion:nil];
            [self.navCatrlArray addObject:navCtrl];
            break;
        }
            
        default:
            break;
    }
}

- (void)returnToFrontView:(BOOL)isAnimated
{
    ControllerShowMode mode = (ControllerShowMode)[[self.showModeArray lastObject] integerValue];
    switch (mode) {
        case ControllerShowModePush:
        {
            [[self getCurNavigationController] popViewControllerAnimated:isAnimated];
            break;
        }
        case ControllerShowModeModel:
        {
            if (self.navCatrlArray.count > 1) {
                [self.navCatrlArray removeLastObject];
                [[self getCurNavigationController] dismissViewControllerAnimated:isAnimated completion:nil];
//                UINavigationController *navVc = (UINavigationController*)[self getCurNavigationController].presentedViewController;
//                UIViewController *vc = [navVc.viewControllers objectAtIndex:0];
            }
            
            
            
            break;
        }
            
        default:
            break;
    }
    [self.showModeArray removeLastObject];
}

- (void)returnToFrontView:(BOOL)isAnimated completion:(completionBlock)completionBlock
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self returnToFrontView:isAnimated];
        
        if (completionBlock) {
            completionBlock([[self getCurNavigationController].viewControllers objectAtIndex:[self getCurNavigationController].viewControllers.count-1]);
        }
    });
    
}

- (void)returnToLoginView:(BOOL)isAnimated
{
    
    [[self rootNavigationController] dismissViewControllerAnimated:NO completion:^{
    }];
    if (self.rootNavigationController.viewControllers.count > 1) {
        [self.rootNavigationController popToViewController:[self.rootNavigationController.viewControllers objectAtIndex:1] animated:YES];
        
        
        
        [self.showModeArray removeObjectsInRange:NSMakeRange(2, self.showModeArray.count-2)];
        [self.navCatrlArray removeObjectsInRange:NSMakeRange(1, self.navCatrlArray.count-1)];
    }
    
}

- (void)returnToMainView:(BOOL)isAnimated
{
    
    [[self rootNavigationController] dismissViewControllerAnimated:NO completion:^{
    }];
    if (self.rootNavigationController.viewControllers.count > 2) {
        [[self rootNavigationController] popToViewController:[self.rootNavigationController.viewControllers objectAtIndex:2] animated:isAnimated];
        
        [self.showModeArray removeObjectsInRange:NSMakeRange(3, self.showModeArray.count-3)];
        [self.navCatrlArray removeObjectsInRange:NSMakeRange(1, self.navCatrlArray.count-1)];
        
    }
}

- (UIViewController*)getMainViewController
{
    if (self.rootNavigationController.viewControllers.count > 2) {
        return [self.rootNavigationController.viewControllers objectAtIndex:2];
    }
    return nil;
}

#pragma mark 返回当前显示controller
- (UIViewController*)curViewController
{
    UINavigationController *nav = [self getCurNavigationController];
    
    if (nav.viewControllers.count) {
        return [nav.viewControllers objectAtIndex:nav.viewControllers.count-1];
    }
    
    
    return nav;
}

- (UINavigationController*)rootNavigationController
{
    if (self.navCatrlArray.count) {
        return [self.navCatrlArray objectAtIndex:0];
    }
    
    return nil;
}

- (UINavigationController*)getCurNavigationController
{
    if (self.navCatrlArray.count) {
        return [self.navCatrlArray lastObject];
    }
    
    return nil;
}

- (UINavigationController*)BaseNavigationControllerWithViewController:(UIViewController*)ctrl
{
    OrientationNavViewController *baseNavCtrl= [[OrientationNavViewController alloc] initWithRootViewController:ctrl];
    [baseNavCtrl setNavigationBarHidden:YES animated:NO];
    return baseNavCtrl;
}

- (void)setShouldAutorotate:(BOOL)autorotate
{
    OrientationNavViewController *vc = (OrientationNavViewController*)[[NavManager shareInstance] rootNavigationController];
    vc.autorotate = autorotate;
}

- (void)setOrietation:(UIInterfaceOrientationMask)orietation
{
    OrientationNavViewController *vc = (OrientationNavViewController*)[[NavManager shareInstance] rootNavigationController];
    vc.orientation = orietation;
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val =  [self abc:orietation];
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (int)abc:(int)a
{
    int b = 0;
    while ( a != 1) {
        a = a/2;
        b++;
    }
    
    return b;
}

- (UIInterfaceOrientationMask)navControllerOrientation
{
    OrientationNavViewController *vc = (OrientationNavViewController*)[[NavManager shareInstance] rootNavigationController];
    return vc.orientation;
}

@end
