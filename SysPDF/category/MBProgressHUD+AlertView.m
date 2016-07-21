//
//  MBProgressHUD+AlertView.m
//  CollectorFrame
//
//  Created by hua on 15/11/20.
//  Copyright © 2015年 hua. All rights reserved.
//

#import "MBProgressHUD+AlertView.h"

@implementation MBProgressHUD (AlertView)
+(void)showAlert:(NSString *)msg inView:(UIView *)view {
    [MBProgressHUD hideAllHUDsForView:view animated:NO];
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:view];
    hud.mode = MBProgressHUDModeText;
    hud.margin = 14;
    hud.labelText = msg;
    [view addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:3];
}

+(void)showAlert:(NSString *)msg inView:(UIView *)view withDuration:(double)delay andThenRetreat:(MBProgressHUDCompletionBlock)retreatBlock {
    [MBProgressHUD hideAllHUDsForView:view animated:NO];
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:view];
    hud.mode = MBProgressHUDModeText;
    hud.margin = 14;
    hud.labelText = msg;
    [view addSubview:hud];
    [hud show:YES];
    //
    dispatch_time_t dispatchSeconds = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(dispatchSeconds, dispatch_get_main_queue(), ^{
        [hud hide:NO];
        retreatBlock();
    });
}

@end
