//
//  PDFManager.h
//  SysPDF
//
//  Created by mutouren on 3/21/16.
//  Copyright © 2016 suyushen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MuPDF/fitz.h>
#import "PDFBookObj.h"


@interface PDFManager : NSObject
{
    fz_rect hitBbox[500];
    float _screenScale;
}

@property (nonatomic, readonly) dispatch_queue_t queue;
@property (nonatomic, readonly) fz_document *doc;
@property (nonatomic, readonly) fz_context *ctx;
@property (nonatomic, assign, readonly) BOOL interactive;
@property (nonatomic, strong) PDFBookObj *openObj;
@property (nonatomic, copy) NSString *error;



+ (PDFManager *)shareInstance;

#pragma mark 打开pdf
- (BOOL)openDocument:(NSString*)fileName;
- (BOOL)initDocument;
- (void)closeDocument;
- (void)setCurrentPage:(NSInteger)page;
- (long)currentPage;
- (long)maxPage;

- (fz_pixmap *)renderPixmap:(fz_document *)doc pageList:(fz_display_list *)page_list displayList:(fz_display_list *)annot_list pageSize:(CGSize )pageSize screenSize:(CGSize )screenSize tileRect:(CGRect )tileRect zoom:(float )zoom;
-(CGSize)fitPageToScreen:(CGSize)page screenSize:(CGSize)screen;
- (UIImage *)newImageWithPixmap:(fz_pixmap *)pix ref:(CGDataProviderRef )cgdata;
- (CGDataProviderRef)CreateWrappedPixmap:(fz_pixmap *)pix;

- (fz_display_list *)create_page_list:(fz_document *)doc page:(fz_page *)page;
- (fz_display_list *)create_annot_list:(fz_document *)doc page:(fz_page *)page;
-(CGSize)measurePage:(fz_page*)page;
- (fz_page*)managerLoadPage:(int)number;


- (NSArray *)enumerateWords:(fz_document *)doc number:(int )number;


@end
