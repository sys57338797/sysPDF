//
//  PDFManager.m
//  SysPDF
//
//  Created by mutouren on 3/21/16.
//  Copyright © 2016 suyushen. All rights reserved.
//

#import "PDFManager.h"
#import <MuPDF/fitz.h>
#import <MuPDF/Mupdf/pdf.h>
#import "PDFMuWord.h"

#import "NSString+StringJudge.h"
#import "CAUserDefaultsManager.h"



@interface PDFManager ()

@property (nonatomic, strong) NSLock *theLock;

@end

@implementation PDFManager

//share Instance of ViewManager
+ (PDFManager *)shareInstance
{
    static PDFManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^ { instance = [[PDFManager alloc] init]; });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("mutouren", NULL);
        // use at most 128M for resource cache
        _ctx = fz_new_context(NULL, NULL, 128<<20);
        fz_register_document_handlers(_ctx);
        _doc = nil;
        _screenScale = [[UIScreen mainScreen] scale];
    }
    
    return self;
}

- (void)setCurrentPage:(NSInteger)page
{
    [self.openObj setCurrentPage:page];
}

- (long)maxPage
{
    return self.openObj.maxPage;
}

- (long)currentPage
{

    return self.openObj.currentPage;
}

- (NSString*)error
{
    NSString *res = [_error copy];
    _error = @"";
    return res;
}

- (void)closeDocument
{
//    __block fz_document *block_doc = _doc;
//    dispatch_async(_queue, ^{
//        fz_drop_document(_ctx, block_doc);
//    });
    fz_drop_document(_ctx, _doc);
    _doc = nil;
}

- (BOOL)initDocument
{
    if (self.openObj) {
        NSString *pdfPath = [self.openObj.bookPath stringByAppendingPathComponent:self.openObj.bookName];
        return [self openDocument:pdfPath];
    }
    else {
        self.error = @"打开的PDF文件对象不能为null";
    }
    
    return NO;
}

#pragma mark 打开pdf
- (BOOL)openDocument:(NSString*)fileName
{
    char filename[PATH_MAX];
    
    if (![fileName fileExtensionsName:@"pdf"]) {
        self.error = @"打开PDF文件出错啦！！！";
        return NO;
    }
    
    dispatch_sync(_queue, ^{});
    
    strcpy(filename, [fileName UTF8String]);
    
    fz_try(_ctx)
    {
        _doc = fz_open_document(_ctx, filename);
        if (!_doc)
        {
            return NO;
        }
        else
        {
            pdf_document *idoc = pdf_specifics(_ctx, _doc);
            if (idoc) pdf_enable_js(_ctx, idoc);
            _interactive = (idoc != NULL) && (pdf_crypt_version(_ctx, idoc) == 0);
        }
    }
    fz_catch(_ctx)
    {
        if (_doc != NULL)
            fz_drop_document(_ctx, _doc);
    }
    
    if (fz_needs_password(_ctx,_doc))
    {
        self.error = @"PDF文件有设置密码！！！";
        return NO;
    }
    
    //读取当前页
    [[CAUserDefaultsManager shareInstance] reloadBookObj:self.openObj];
    //设置最大页
    [self.openObj setMaxPage:[self maxPageCount]];
    
    return YES;
}

- (NSArray *)enumerateWords:(fz_document *)doc fz_page:(fz_page*)page
{
    fz_text_sheet *sheet = NULL;
    fz_text_page *text = NULL;
    fz_device *dev = NULL;
    NSMutableArray *lns = [NSMutableArray array];
    NSMutableArray *wds;
    PDFMuWord *word;
    
    if (!lns)
        return NULL;
    
    fz_var(sheet);
    fz_var(text);
    fz_var(dev);
    
    fz_try(_ctx);
    {
        int b, l, c;
        
        sheet = fz_new_text_sheet(_ctx);
        text = fz_new_text_page(_ctx);
        dev = fz_new_text_device(_ctx, sheet, text);
        fz_run_page(_ctx, page, dev, &fz_identity, NULL);
        fz_drop_device(_ctx, dev);
        dev = NULL;
        
        for (b = 0; b < text->len; b++)
        {
            fz_text_block *block;
            
            if (text->blocks[b].type != FZ_PAGE_BLOCK_TEXT)
                continue;
            
            block = text->blocks[b].u.text;
            
            for (l = 0; l < block->len; l++)
            {
                fz_text_line *line = &block->lines[l];
                fz_text_span *span;
                
                wds = [NSMutableArray array];
                if (!wds)
                    fz_throw(_ctx, FZ_ERROR_GENERIC, "Failed to create word array");
                
                word = [PDFMuWord word];
                if (!word)
                    fz_throw(_ctx, FZ_ERROR_GENERIC, "Failed to create word");
                
                for (span = line->first_span; span; span = span->next)
                {
                    for (c = 0; c < span->len; c++)
                    {
                        fz_text_char *ch = &span->text[c];
                        fz_rect bbox;
                        CGRect rect;
                        
                        fz_text_char_bbox(_ctx, &bbox, span, c);
                        rect = CGRectMake(bbox.x0, bbox.y0, bbox.x1 - bbox.x0, bbox.y1 - bbox.y0);
                        
                        if (ch->c != ' ')
                        {
                            unichar buf = ch->c;
                            [word appendChar:buf withRect:rect];
                        }
                        else if (word.content.length > 0)
                        {
                            [wds addObject:word];
                            word = [PDFMuWord word];
                            if (!word)
                                fz_throw(_ctx, FZ_ERROR_GENERIC, "Failed to create word");
                        }
                    }
                }
                
                if (word.content.length > 0)
                    [wds addObject:word];
                
                if ([wds count] > 0)
                    [lns addObject:wds];
            }
        }
    }
    fz_always(_ctx);
    {
        fz_drop_text_page(_ctx, text);
        fz_drop_text_sheet(_ctx, sheet);
        fz_drop_device(_ctx, dev);
    }
    fz_catch(_ctx)
    {
        lns = NULL;
    }
    
    return lns;
}

-(CGSize)fitPageToScreen:(CGSize)page screenSize:(CGSize)screen
{
    float hscale = screen.width / page.width;
    float vscale = screen.height / page.height;
    float scale = fz_min(hscale, vscale);
    hscale = floorf(page.width * scale) / page.width;
    vscale = floorf(page.height * scale) / page.height;
    return CGSizeMake(hscale, vscale);
}

-(CGSize)measurePage:(fz_page*)page
{
    CGSize pageSize = CGSizeZero;
    
    fz_try(_ctx)
    {
        fz_rect bounds;
        fz_bound_page(_ctx, page, &bounds);
        pageSize.width = bounds.x1 - bounds.x0;
        pageSize.height = bounds.y1 - bounds.y0;
    }
    fz_catch(_ctx)
    {
        return pageSize;
    }
    
    return pageSize;
}

- (int)search_page:(fz_document *)doc number:(int )number needle:(char *)needle cookie:(fz_cookie *)cookie
{
    fz_page *page = fz_load_page(_ctx, doc, number);
    
    fz_text_sheet *sheet = fz_new_text_sheet(_ctx);
    fz_text_page *text = fz_new_text_page(_ctx);
    fz_device *dev = fz_new_text_device(_ctx, sheet, text);
    fz_run_page(_ctx, page, dev, &fz_identity, cookie);
    fz_drop_device(_ctx, dev);
    
    int hit_count = fz_search_text_page(_ctx, text, needle, hitBbox, nelem(hitBbox));
    
    fz_drop_text_page(_ctx, text);
    fz_drop_text_sheet(_ctx, sheet);
    fz_drop_page(_ctx, page);
    
    return hit_count;
}

- (fz_rect)search_result_bbox:(fz_document *)doc index:(int)i
{
    return hitBbox[i];
}

static void releasePixmap(void *info, const void *data, size_t size)
{
    if ([PDFManager shareInstance].queue)
        dispatch_async([PDFManager shareInstance].queue, ^{
            fz_drop_pixmap([PDFManager shareInstance].ctx, info);
        });
    else
    {
        fz_drop_pixmap([PDFManager shareInstance].ctx, info);
    }
}

- (CGDataProviderRef)CreateWrappedPixmap:(fz_pixmap *)pix
{
    unsigned char *samples = fz_pixmap_samples(_ctx, pix);
    int w = fz_pixmap_width(_ctx, pix);
    int h = fz_pixmap_height(_ctx, pix);
    return CGDataProviderCreateWithData(pix, samples, w * 4 * h, releasePixmap);
}

- (CGImageRef)CreateCGImageWithPixmap:(fz_pixmap *)pix ref:(CGDataProviderRef )cgdata
{
    int w = fz_pixmap_width(_ctx, pix);
    int h = fz_pixmap_height(_ctx, pix);
    CGColorSpaceRef cgcolor = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgimage = CGImageCreate(w, h, 8, 32, 4 * w, cgcolor, kCGBitmapByteOrderDefault, cgdata, NULL, NO, kCGRenderingIntentDefault);
    CGColorSpaceRelease(cgcolor);
    return cgimage;
}

- (UIImage *)newImageWithPixmap:(fz_pixmap *)pix ref:(CGDataProviderRef )cgdata
{
    CGImageRef cgimage = [self CreateCGImageWithPixmap:pix ref:cgdata];
    UIImage *image = [[UIImage alloc] initWithCGImage: cgimage scale:_screenScale orientation: UIImageOrientationUp];
    CGImageRelease(cgimage);
    return image;
}

- (fz_pixmap *)renderPixmap:(fz_document *)doc pageList:(fz_display_list *)page_list displayList:(fz_display_list *)annot_list pageSize:(CGSize )pageSize screenSize:(CGSize )screenSize tileRect:(CGRect )tileRect zoom:(float )zoom
{
    fz_irect bbox;
    fz_rect rect;
    fz_matrix ctm;
    fz_device *dev = NULL;
    fz_pixmap *pix = NULL;
    CGSize scale;
    
    screenSize.width *= _screenScale;
    screenSize.height *= _screenScale;
    tileRect.origin.x *= _screenScale;
    tileRect.origin.y *= _screenScale;
    tileRect.size.width *= _screenScale;
    tileRect.size.height *= _screenScale;
    
    scale = [self fitPageToScreen:pageSize screenSize:screenSize];
    fz_scale(&ctm, scale.width * zoom, scale.height * zoom);
    
    bbox.x0 = tileRect.origin.x;
    bbox.y0 = tileRect.origin.y;
    bbox.x1 = tileRect.origin.x + tileRect.size.width;
    bbox.y1 = tileRect.origin.y + tileRect.size.height;
    fz_rect_from_irect(&rect, &bbox);
    
    [self.theLock lock];
    fz_var(dev);
    fz_var(pix);
    fz_try(_ctx)
    {
        pix = fz_new_pixmap_with_bbox(_ctx, fz_device_rgb(_ctx), &bbox);
        fz_clear_pixmap_with_value(_ctx, pix, 255);
        
        dev = fz_new_draw_device(_ctx, pix);
        fz_run_display_list(_ctx, page_list, dev, &ctm, &rect, NULL);
        fz_run_display_list(_ctx, annot_list, dev, &ctm, &rect, NULL);
    }
    fz_always(_ctx)
    {
        fz_drop_device(_ctx, dev);
    }
    fz_catch(_ctx)
    {
        fz_drop_pixmap(_ctx, pix);
        [self.theLock unlock];
        return NULL;
    }
    [self.theLock unlock];
    
    return pix;
}

- (fz_display_list *)create_page_list:(fz_document *)doc page:(fz_page *)page
{
    fz_display_list *list = NULL;
    fz_device *dev = NULL;
    
    [self.theLock lock];
    fz_var(dev);
    fz_try(_ctx)
    {
        list = fz_new_display_list(_ctx);
        dev = fz_new_list_device(_ctx, list);
        fz_run_page_contents(_ctx, page, dev, &fz_identity, NULL);
    }
    fz_always(_ctx)
    {
        fz_drop_device(_ctx, dev);
    }
    fz_catch(_ctx)
    {
        [self.theLock unlock];
        return NULL;
    }
    [self.theLock unlock];
    
    return list;
}

- (fz_display_list *)create_annot_list:(fz_document *)doc page:(fz_page *)page
{
    fz_display_list *list = NULL;
    fz_device *dev = NULL;
    
    [self.theLock lock];
    fz_var(dev);
    fz_try(_ctx)
    {
        fz_annot *annot;
        pdf_document *idoc = pdf_specifics(_ctx, doc);
        
        if (idoc)
            pdf_update_page(_ctx, idoc, (pdf_page *)page);
        list = fz_new_display_list(_ctx);
        dev = fz_new_list_device(_ctx, list);
        for (annot = fz_first_annot(_ctx, page); annot; annot = fz_next_annot(_ctx, page, annot))
            fz_run_annot(_ctx, page, annot, dev, &fz_identity, NULL);
    }
    fz_always(_ctx)
    {
        fz_drop_device(_ctx, dev);
    }
    fz_catch(_ctx)
    {
        [self.theLock unlock];
        return NULL;
    }
    [self.theLock unlock];
    
    return list;
}

- (fz_page*)managerLoadPage:(int)number
{
    fz_page *page = nil;
    fz_try(_ctx)
    {
        [self.theLock lock];
        page = fz_load_page(_ctx, self.doc, number);
    }
    fz_catch(_ctx)
    {
        [self.theLock unlock];
        return page;
    }
    
    [self.theLock unlock];
    return page;
}

- (NSInteger)maxPageCount
{
    if (_ctx&&self.doc) {
        return fz_count_pages(_ctx, self.doc);
    }
    return 0;
}

- (NSLock*)theLock
{
    if (!_theLock) {
        _theLock = [[NSLock alloc] init];
    }
    
    return _theLock;
}

@end
