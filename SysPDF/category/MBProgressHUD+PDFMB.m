//
//  MBProgressHUD+gjMB.m
//  GJChargeSystem
//
//  Created by 廖维海 on 15/4/29.
//  Copyright (c) 2015年 www.cheweiguanjia.com. All rights reserved.
//

#import "MBProgressHUD+PDFMB.h"

@implementation MBProgressHUD (PDFMB)

+ (void)showHUDWithText:(NSString *)text view:(UIView *)view
{
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    }
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    hud.labelFont = [UIFont systemFontOfSize:13];
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:1.5];
}

+ (void)showHUDInBottonWithText:(NSString *)text view:(UIView *)view
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.minSize = CGSizeMake(width - (0.2 * width), 30);
    hud.yOffset = (height * 0.5 - 100);
    hud.labelText = text;
    hud.labelFont = [UIFont systemFontOfSize:12];
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:1.5];
}

+ (MBProgressHUD *)showProgressHUDWithText:(NSString *)text view:(UIView *)view
{
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    //hud.color = [UIColor colorWithRed:249/255.0 green:196/255.0 blue:32/255.0 alpha:1];
    hud.labelFont = [UIFont systemFontOfSize:13];
    hud.labelText = text;
    //    hud.labelColor = [UIColor blueColor];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    return hud;
}

+ (MBProgressHUD *)showProgressHUDWithText:(NSString *)text{
    
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.labelFont = [UIFont systemFontOfSize:13];
    hud.labelText = text;
    hud.mode = MBProgressHUDModeIndeterminate;
    
    return hud;
}

+ (void)hideAllInWindow
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    [MBProgressHUD hideAllHUDsForView:window animated:YES];
}

- (void)hideAllWithView:(UIView *)view
{
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

+ (void)showHUDWithText:(NSString *)text hideDelay:(float)delay
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    [hud hide:YES afterDelay:delay];
}

+ (void)showHUDWithDetailsText:(NSString *)text hideDelay:(float)delay
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = text;
//    [hud setDetailsLabelTextAlignment:NSTextAlignmentLeft];
    [hud hide:YES afterDelay:delay];
}

+ (void)showHUDWithText:(NSString *)text view:(UIView *)view HUDCompletionBlock:(MBProgressHUDCompletionBlock)completionBlock
{
    
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    }
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    hud.labelFont = [UIFont systemFontOfSize:13];
    hud.mode = MBProgressHUDModeText;
    if (completionBlock) {
        [hud setCompletionBlock:completionBlock];
    }
    [hud hide:YES afterDelay:1.5];
}

@end
