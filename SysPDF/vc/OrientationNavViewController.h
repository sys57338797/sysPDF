//
//  OrientationNavViewController.h
//  SysPDF
//
//  Created by mutouren on 4/8/16.
//  Copyright © 2016 suyushen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrientationNavViewController : UINavigationController

@property (nonatomic, assign) UIInterfaceOrientationMask orientation;
@property (nonatomic, assign) BOOL autorotate;


@end
