//
//  CAUserDefaultsManager.h
//  CWGJCarPark
//
//  Created by mutouren on 9/7/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//  userDefault类 存到文件

#import <Foundation/Foundation.h>
#import "PDFBookObj.h"


typedef void(^managerLoadWordCompletionBlock)(NSDictionary *wordDictionary);


@interface CAUserDefaultsManager : NSObject


//share Instance of NavManager
+ (CAUserDefaultsManager *)shareInstance;

#pragma mark 返回所有单词
- (void)wordDictionaryFileLoadCompletion:(managerLoadWordCompletionBlock)completion;

#pragma mark 返回未翻译的单词
- (NSMutableArray*)nonTranslationWordArray;

#pragma mark 返回PDF文件名称
- (NSMutableArray*)PDFFileNameArray;

#pragma mark 更新未翻译
- (void)updateNonTranslationWordArray:(NSArray*)array;

#pragma mark 更新单词表
- (void)updateWordDictionary:(NSDictionary*)dictionary;

#pragma mark 读取bookObj
- (void)reloadBookObj:(PDFBookObj*)obj;

@end
