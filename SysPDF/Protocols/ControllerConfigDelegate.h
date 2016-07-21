//
//  ControllerConfigDelegate.h
//  BaseMVVM
//
//  Created by suyushen on 15/8/14.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//

#ifndef BaseMVVM_ControllerConfigDelegate_h
#define BaseMVVM_ControllerConfigDelegate_h

@protocol ControllerConfigDelegate <NSObject>


@optional
#pragma mark viewWillAppear 调用
- (void)loadNotification;

#pragma mark viewWillDisappear 调用
- (void)unLoadNotification;

#pragma mark loadView 调佣
- (void)loadUI;

#pragma mark viewDidLoad 调用
- (void)loadData;


#pragma mark view动作返回给controller
-(void) sendToCtrlWithAction:(NSInteger) action param:(NSDictionary *) param;


@end


#endif
