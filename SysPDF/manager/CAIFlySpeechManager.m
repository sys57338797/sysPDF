//
//  CADataCacheManager.m
//  CWGJCarPark
//
//  Created by mutouren on 9/7/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//

#import "CAIFlySpeechManager.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySetting.h"
#import "NSNotificationCenter+Extra.h"


@interface CAIFlySpeechManager () <IFlySpeechSynthesizerDelegate>

@property (nonatomic, strong) NSMutableArray *msgArray;
@property (nonatomic, strong) NSLock *theLock;

@end

@implementation CAIFlySpeechManager




//share Instance of ViewManager
+ (CAIFlySpeechManager *)shareInstance
{
    static CAIFlySpeechManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^ { instance = [[CAIFlySpeechManager alloc] init]; });
    return instance;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.msgArray = [NSMutableArray array];
        self.theLock = [[NSLock alloc] init];
        [[IFlySpeechSynthesizer sharedInstance] setDelegate:self];
        [self configIFlySpeech];
        
        [NSNotificationCenter addObserverExt:self selector:@selector(AppBecomeActiveNotification) msgName:UIApplicationDidBecomeActiveNotification object:nil];
        [NSNotificationCenter addObserverExt:self selector:@selector(AppResignActiveNotification) msgName:UIApplicationWillResignActiveNotification object:nil];
        
    }
    return self;
}

#pragma mark 进入前台时
- (void)AppBecomeActiveNotification
{
    [[IFlySpeechSynthesizer sharedInstance] resumeSpeaking];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (![[IFlySpeechSynthesizer sharedInstance] isSpeaking]) {
            [self startPlayMessage];
        }
    });
}

#pragma mark 进入后台时
- (void)AppResignActiveNotification
{
    if ([[IFlySpeechSynthesizer sharedInstance] isSpeaking]) {
        [[IFlySpeechSynthesizer sharedInstance] pauseSpeaking];
    }
}

- (void)playMsg:(NSString*)msg
{
    [self addMsgString:msg];
    if (![[IFlySpeechSynthesizer sharedInstance] isSpeaking]) {
        [self startPlayMessage];
    }
}

- (void)addMsgString:(NSString*)msg
{
    if (msg&&msg.length) {
        [self.theLock lock];
        [self.msgArray addObject:[NSString stringWithFormat:@"%@",msg]];
        [self.theLock unlock];
    }
}

#pragma mark 开始播报消息
- (void)startPlayMessage
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if (self.msgArray.count) {
            [self.theLock lock];
            NSString *msg = [NSString stringWithFormat:@"%@",[self.msgArray objectAtIndex:0]];
            [self.msgArray removeObject:msg];
            [self.theLock unlock];
            
            if (msg&&msg.length) {
                NSString *text = [msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [[IFlySpeechSynthesizer sharedInstance] startSpeaking:text];
            }
        }
    }
}

#pragma mark 停止播报消息
- (void)stopPlay
{
    if ([[IFlySpeechSynthesizer sharedInstance] isSpeaking]) {
        [[IFlySpeechSynthesizer sharedInstance] stopSpeaking];
    }
}

- (void)configIFlySpeech
{
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",kiFlyKey,@"20000"];
    [IFlySpeechUtility createUtility:initString];
    
    [IFlySetting setLogFile:LVL_ALL];
    [IFlySetting showLogcat:NO];
    
    // 设置语音合成的参数
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"30" forKey:[IFlySpeechConstant SPEED]];//合成的语速,取值范围 0~100
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"80" forKey:[IFlySpeechConstant VOLUME]];//合成的音量;取值范围 0~100
    
    // 发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表;
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"Catherine" forKey:[IFlySpeechConstant VOICE_NAME]];
    
    // 音频采样率,目前支持的采样率有 16000 和 8000;
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"8000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    // 当你再不需要保存音频时，请在必要的地方加上这行。
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"tts.pcm" forKey:[IFlySpeechConstant TTS_AUDIO_PATH]];
}

#pragma mark - IFlySpeechSynthesizerDelegate
- (void) onCompleted:(IFlySpeechError*) error
{
    NSLog(@"onCompleted===>%@",[NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc]);
}

- (void) onSpeakBegin
{
    NSLog(@"onSpeakBegin");
}

- (void) onSpeakProgress:(int) progress
{
    if (progress == 100) {
        [self startPlayMessage];
    }
}

@end
