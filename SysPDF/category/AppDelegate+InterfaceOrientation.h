//
//  AppDelegate+InterfaceOrientation.h
//  SysPDF
//
//  Created by mutouren on 4/8/16.
//  Copyright © 2016 suyushen. All rights reserved.
//

#import "AppDelegate.h"

UIKIT_EXTERN NSString *const KInterfaceOrientationNotification;

@interface AppDelegate (InterfaceOrientation)

- (void)setupInterfaceOrientation;

@end
