//
//  MBProgressHUD+AlertView.h
//  CollectorFrame
//
//  Created by hua on 15/11/20.
//  Copyright © 2015年 hua. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (AlertView)
+(void)showAlert:(NSString *)msg inView:(UIView *)view;
+(void)showAlert:(NSString *)msg inView:(UIView *)view withDuration:(double)delay andThenRetreat:(MBProgressHUDCompletionBlock)retreatBlock;
@end
