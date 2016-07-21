//
//  CADataCacheManager.h
//  CWGJCarPark
//
//  Created by mutouren on 9/7/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//  播报语音类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface CAIFlySpeechManager : NSObject


//share Instance of NavManager
+ (CAIFlySpeechManager *)shareInstance;

#pragma mark 播放语音
- (void)playMsg:(NSString*)msg;

#pragma mark 开始播报消息
- (void)startPlayMessage;

#pragma mark 停止播报消息
- (void)stopPlay;


@end
