//
//  UIViewController+Factory.h
//  BaseMVVM
//
//  Created by suyushen on 15/8/14.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//  UIViewController 工厂类

#import <UIKit/UIKit.h>



#pragma mark - 视图控制器的类别
typedef enum {
    CtrlTag_None = 0,               //保留字段
    CtrlTag_Main,                   //主页
    CtrlTag_FileList,               //文件列表
    CtrlTag_PDFDocument,            //PDF内容页
    CtrlTag_Word,                   //单词页
    CtrlTag_Translation,            //翻译页
}CtrlTag;


@interface UIViewController (Factory)

+(UIViewController*)CreateControllerWithTag:(CtrlTag)tag;

@end
