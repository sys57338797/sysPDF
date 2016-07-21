//
//  NSNotificationCenter+Extra.h
//  BaseMVVM
//
//  Created by mutouren on 15/8/21.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//  通知类，防止多次监听某个消息

#import <Foundation/Foundation.h>

//Notification消息前缀
static NSString const *kNotifyMsgIdName=@"notMsgID:";

@interface NSNotificationCenter (Extra)

#pragma mark 传int型ID
+ (void)addObserverExt:(id)notificationObserver
              selector:(SEL)notificationSelector
                  msgID:(NSUInteger)notifyMsgID
                object:(id)notificationSender;

#pragma mark 传消息名称
+ (void)addObserverExt:(id)notificationObserver
              selector:(SEL)notificationSelector
                  msgName:(NSString*)msgName
                object:(id)notificationSender;

+ (void)removeObserverExt:(id)notificationObserver
                     msgName:(NSString*)msgName
                   object:(id)notificationSender;

+ (void)removeObserverExt:(id)notificationObserver
                     msgID:(NSUInteger)notifyMsgID
                   object:(id)notificationSender;

@end
