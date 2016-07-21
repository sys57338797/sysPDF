//
//  CADataCacheManager.m
//  CWGJCarPark
//
//  Created by mutouren on 9/7/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//

#import "CADataCacheManager.h"
#import "CAUserDefaultsManager.h"

#define updateDataMinute 3

@interface CADataCacheManager ()

@property (nonatomic, strong) NSMutableDictionary *allWordDictionary;         //单词字典

@property (nonatomic, strong) NSLock *theLock;
@property (nonatomic, strong) NSTimer *theTimer;

@end

@implementation CADataCacheManager


//share Instance of ViewManager
+ (CADataCacheManager *)shareInstance
{
    static CADataCacheManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^ { instance = [[CADataCacheManager alloc] init]; });
    return instance;
}

-(id)init
{
    self = [super init];
    if (self) {
        
        _allWordDictionary = [NSMutableDictionary dictionary];
        
        _nonTranslationWordArray = [NSMutableArray array];
        
        _PDFFileNameArray = [NSMutableArray array];
        
        [self loadUserDefaultData];
        
        [self.theTimer setFireDate:[NSDate distantPast]];
        
        PDFWordObj *obj = [[PDFWordObj alloc] init];
        obj.ENContent = @"good";
        obj.ukPhonetic = @"gud";
        obj.CHContent = @"好";
        obj.webCHContentArray = [NSMutableArray arrayWithArray:@[@"n:haohaohao",@"adj:haohaoaho"]];
        [self.nonTranslationWordArray addObject:obj];
    }
    return self;
}

- (void)dealloc
{
    [self.theTimer setFireDate:[NSDate distantFuture]];
    [self.theTimer invalidate];
    self.theTimer = nil;
}

#pragma mark 去读userDefault文件缓存
- (void)loadUserDefaultData
{
    _nonTranslationWordArray = [[CAUserDefaultsManager shareInstance] nonTranslationWordArray];
    
    _PDFFileNameArray = [[CAUserDefaultsManager shareInstance] PDFFileNameArray];
    
    [[CAUserDefaultsManager shareInstance] wordDictionaryFileLoadCompletion:^(NSDictionary *wordDictionary) {
        
        if (wordDictionary&&wordDictionary.allKeys.count) {
            [self.theLock lock];
            
            NSArray *keyArray = [wordDictionary allKeys];
            
            for (NSString *key in keyArray) {
                NSMutableArray *wordArray = [self.allWordDictionary objectForKey:key];
                NSMutableArray *newWordArray = [wordDictionary objectForKey:key];
                if (wordArray) {
                    [wordArray addObjectsFromArray:newWordArray];
                }
                else {
                    [self.allWordDictionary setObject:newWordArray forKey:key];
                }
            }
            
            [self.theLock unlock];
        }
    }];
}

- (NSMutableDictionary*)getAllWordDictionary
{
    NSMutableDictionary *res = nil;
    [self.theLock lock];
    res = _allWordDictionary;
    [self.theLock unlock];
    
    return res;
}

#pragma mark 未翻译单词添加单词
- (void)nonTranslationWordArrayAddObj:(PDFWordObj*)obj
{
    [_nonTranslationWordArray addObject:obj];
}

#pragma mark 未翻译单词移除单词
- (void)nonTranslationWordArrayRemoveObj:(PDFWordObj*)obj
{
    [_nonTranslationWordArray removeObject:obj];
}

#pragma mark 单词表添加单词
- (void)wordDictionaryAddObj:(PDFWordObj*)obj
{
    NSString *key = @"";
    if (obj.ENContent.length) {
        key = [[obj ENContent] substringToIndex:1];
    }
    
    if (key.length) {
        [self.theLock lock];
        
        NSMutableArray *wordArray = [self.allWordDictionary objectForKey:key];
        if (!wordArray) {
            wordArray = [NSMutableArray array];
        }
        
        [wordArray addObject:obj];
        
        [self.allWordDictionary setObject:wordArray forKey:key];
        
        [self.theLock unlock];
    }
    
}

#pragma mark 单词表移除单词
- (void)wordDictionaryRemoveObj:(PDFWordObj*)obj
{
    NSString *key = @"";
    if (obj.ENContent.length) {
        key = [[obj ENContent] substringToIndex:1];
    }
    
    if (key.length) {
        [self.theLock lock];
        
        NSMutableArray *wordArray = [self.allWordDictionary objectForKey:key];
        if (wordArray) {
            if ([wordArray containsObject:obj]) {
                [wordArray removeObject:obj];
            }
        }
        
        [self.allWordDictionary setObject:wordArray forKey:key];
        
        [self.theLock unlock];
    }
}

- (void)updateWordLogic
{
    [[CAUserDefaultsManager shareInstance] updateNonTranslationWordArray:self.nonTranslationWordArray];
    [[CAUserDefaultsManager shareInstance] updateWordDictionary:self.allWordDictionary];
}

- (NSLock*)theLock
{
    if (!_theLock) {
        _theLock = [[NSLock alloc] init];
    }
    
    return _theLock;
}

- (NSTimer*)theTimer
{
    if (!_theTimer) {
        _theTimer = [NSTimer timerWithTimeInterval:(60*updateDataMinute) target:self selector:@selector(updateWordLogic) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_theTimer forMode:NSDefaultRunLoopMode];

    }
    
    return _theTimer;
}

@end
