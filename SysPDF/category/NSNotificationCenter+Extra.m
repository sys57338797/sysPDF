//
//  NSNotificationCenter+Extra.m
//  BaseMVVM
//
//  Created by mutouren on 15/8/21.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//

#import "NSNotificationCenter+Extra.h"

@implementation NSNotificationCenter (Extra)

+ (void)addObserverExt:(id)notificationObserver
              selector:(SEL)notificationSelector
                 msgID:(NSUInteger)notifyMsgID
                object:(id)notificationSender
{
    NSString* sNotName = [NSString stringWithFormat:@"%@%llu", kNotifyMsgIdName, (unsigned long long)notifyMsgID];
    [self addObserverExt:notificationObserver selector:notificationSelector msgName:sNotName object:notificationSender];
}

+ (void)addObserverExt:(id)notificationObserver
              selector:(SEL)notificationSelector
                  msgName:(NSString*)msgName
                object:(id)notificationSender
{
    [self removeObserverExt:notificationObserver msgName:msgName object:notificationSender];
    [[NSNotificationCenter defaultCenter] addObserver:notificationObserver
                                             selector:notificationSelector
                                                 name:msgName
                                               object:notificationSender];
}

+ (void)removeObserverExt:(id)notificationObserver
                     msgName:(NSString*)msgName
                   object:(id)notificationSender
{
    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver
                                                    name:msgName
                                                  object:notificationSender];
}

+ (void)removeObserverExt:(id)notificationObserver
                     msgID:(NSUInteger)notifyMsgID
                   object:(id)notificationSender
{
    NSString* sNotName = [NSString stringWithFormat:@"%@%llu", kNotifyMsgIdName, (unsigned long long)notifyMsgID];
    [self removeObserverExt:notificationObserver msgName:sNotName object:notificationSender];
}

@end
