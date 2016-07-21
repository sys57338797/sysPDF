//
//  UIViewController+Factory.m
//  BaseMVVM
//
//  Created by suyushen on 15/8/14.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//

#import "UIViewController+Factory.h"
#import "PDFDocumentController.h"
#import "PDFFilesViewController.h"
#import "PDFMainViewController.h"
#import "PDFWordTableViewController.h"
#import "PDFTranslationViewController.h"


@implementation UIViewController (Factory)


+(UIViewController*)CreateControllerWithTag:(CtrlTag)tag
{
    UIViewController *resCtrl = nil;
    
    switch (tag) {
        case CtrlTag_Main:
        {
            resCtrl = [[PDFMainViewController alloc] init];
            break;
        }
        case CtrlTag_FileList:
        {
            resCtrl = [[PDFFilesViewController alloc] init];
            break;
        }
        case CtrlTag_PDFDocument:
        {
            resCtrl = [[PDFDocumentController alloc] init];
            break;
        }
        case CtrlTag_Word:
        {
            resCtrl = [[PDFWordTableViewController alloc] init];
            break;
        }
        case CtrlTag_Translation:
        {
            resCtrl = [[PDFTranslationViewController alloc] init];
            break;
        }
        default:
            break;
    }
    
    return resCtrl;
}


@end
