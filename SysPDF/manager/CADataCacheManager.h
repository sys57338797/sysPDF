//
//  CADataCacheManager.h
//  CWGJCarPark
//
//  Created by mutouren on 9/7/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//  数据缓存类

#import <Foundation/Foundation.h>
#import "PDFWordObj.h"

@interface CADataCacheManager : NSObject


@property (nonatomic, strong, readonly) NSMutableArray *nonTranslationWordArray;        //未翻译的单词
@property (nonatomic, strong, readonly) NSMutableArray *PDFFileNameArray;               //PDF文件数组

//share Instance of NavManager
+ (CADataCacheManager *)shareInstance;

#pragma mark 去读userDefault文件缓存
- (void)loadUserDefaultData;

#pragma mark 单词字典
- (NSMutableDictionary*)getAllWordDictionary;

#pragma mark 未翻译单词添加单词
- (void)nonTranslationWordArrayAddObj:(PDFWordObj*)obj;

#pragma mark 未翻译单词移除单词
- (void)nonTranslationWordArrayRemoveObj:(PDFWordObj*)obj;

#pragma mark 单词表添加单词
- (void)wordDictionaryAddObj:(PDFWordObj*)obj;

#pragma mark 单词表移除单词
- (void)wordDictionaryRemoveObj:(PDFWordObj*)obj;


@end
