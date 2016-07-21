//
//  MBProgressHUD+gjMB.h
//  GJChargeSystem
//
//  Created by 廖维海 on 15/4/29.
//  Copyright (c) 2015年 www.cheweiguanjia.com. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (PDFMB)

+ (void)showHUDWithText:(NSString *)text view:(UIView *)view;

+ (void)showHUDInBottonWithText:(NSString *)text view:(UIView *)view;

+ (MBProgressHUD *)showProgressHUDWithText:(NSString *)text view:(UIView *)view;

+ (void)showHUDWithDetailsText:(NSString *)text hideDelay:(float)delay;

+ (void)showHUDWithText:(NSString *)text hideDelay:(float)delay;


+ (MBProgressHUD *)showProgressHUDWithText:(NSString *)text;

+ (void)hideAllInWindow;

+ (void)showHUDWithText:(NSString *)text view:(UIView *)view HUDCompletionBlock:(MBProgressHUDCompletionBlock)completionBlock;

@end
