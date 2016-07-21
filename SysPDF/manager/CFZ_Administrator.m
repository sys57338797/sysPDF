//
//  CFZ_Administrator.m
//  MuPDF
//
//  Created by mutouren on 6/28/13.
//
//

#import "CFZ_Administrator.h"
//#include "fitz/doc_search.c"


/*
 NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:[CFZ_Administrator getParticularString]];
 NSString *outString = [word stringByTrimmingCharactersInSet:set];
 if (outString.length) {
 NSString *key = [NSString stringWithFormat:@"%@",outString];
 id value = [_pageOfWordsDictionary objectForKey:key];
 if (value) {
 
 }
 else {
 [_pageOfWordsDictionary setObject:[NSNull null] forKey:key];
 }
 */

//#define particularString @"@\"\"~1~2~3~4~5~6~7~8~9~0~'~]~[~{~}~,~."
#define particularString @"\@~\:~\(~\)~\"~\"~1~2~3~4~5~6~7~8~9~0~'~\]~\[~\{~\}~,~."


@implementation FZWordInfoObj


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.text = [aDecoder decodeObjectForKey:@"FZWordInfoObjText"];
        CGFloat x = [[aDecoder decodeObjectForKey:@"FZWordInfoObjRectOriginX"] floatValue];
        CGFloat y = [[aDecoder decodeObjectForKey:@"FZWordInfoObjRectOriginY"] floatValue];
        CGFloat w = [[aDecoder decodeObjectForKey:@"FZWordInfoObjRectOriginW"] floatValue];
        CGFloat h = [[aDecoder decodeObjectForKey:@"FZWordInfoObjRectOriginH"] floatValue];
        _rect.x0 = x;
        _rect.y0 = y;
        _rect.x1 = x+w;
        _rect.y1 = y+h;
        self.charLength = [[aDecoder decodeObjectForKey:@"FZWordInfoObjCharLength"] integerValue];
        self.spanIndex = [[aDecoder decodeObjectForKey:@"FZWordInfoObjSpanIndex"] integerValue];
        self.charIndex = [[aDecoder decodeObjectForKey:@"FZWordInfoObjCharIndex"] integerValue];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_text forKey:@"FZWordInfoObjText"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_rect.x0] forKey:@"FZWordInfoObjRectOriginX"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_rect.y0] forKey:@"FZWordInfoObjRectOriginY"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_rect.x1-_rect.x0] forKey:@"FZWordInfoObjRectOriginW"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_rect.y1-_rect.y0] forKey:@"FZWordInfoObjRectOriginH"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_charLength] forKey:@"FZWordInfoObjCharLength"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_spanIndex] forKey:@"FZWordInfoObjSpanIndex"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_charIndex] forKey:@"FZWordInfoObjCharIndex"];
}

@end

@implementation CFZ_Administrator


static void releasePixmap(void *info, const void *data, size_t size)
{
	fz_drop_pixmap([CFZ_Administrator shareInstance].ctx, info);
}

#pragma mark 去除多余的字符串
+(NSString*)getNSCharactersetWithNSString:(NSString*)text
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:[CFZ_Administrator getParticularString]];
    NSString *outString = [text stringByTrimmingCharactersInSet:set];
    
    NSString *resString = [[NSString alloc] initWithFormat:@"%@",outString.length?outString:@""];
    return resString;
}

+(NSString*)getParticularString
{
    NSString *resString = [NSString stringWithFormat:@"%@",particularString];
    NSArray *array = [resString componentsSeparatedByString:@"~"];
    NSMutableString *mutableString = [NSMutableString stringWithCapacity:0];
    for (NSString *s in array) {
        [mutableString appendFormat:@"%@",s];
    }
    return [[NSString alloc] initWithString:mutableString];
}

static CFZ_Administrator *instance;
+ (CFZ_Administrator *)shareInstance
{
    if (!instance) {
        instance = [[CFZ_Administrator alloc] init];
    }
    return instance;
}


-(id)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("mutouren", NULL);
        // use at most 128M for resource cache
        _ctx = fz_new_context(NULL, NULL, 128<<20);
        _doc = nil;
        _screenScale = [[UIScreen mainScreen] scale];
        _curPageIndex = 0;
        _dataArray = [[NSMutableArray alloc] initWithCapacity:0];
        _unDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.curDocumentFileName = [aDecoder decodeObjectForKey:@"curDocumentFileName"];
        self.curDocumentFilePath = [aDecoder decodeObjectForKey:@"curDocumentFilePath"];
        self.curPageIndex = [[aDecoder decodeObjectForKey:@"curPageIndex"] integerValue];
        self.searchWordObj = [aDecoder decodeObjectForKey:@"searchWordObj"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_curDocumentFileName forKey:@"curDocumentFileName"];
    [aCoder encodeObject:_curDocumentFilePath forKey:@"curDocumentFilePath"];
    [aCoder encodeInteger:_curPageIndex forKey:@"curPageIndex"];
    [aCoder encodeObject:_searchWordObj];
}

#pragma mark 返回最大页数
-(NSInteger)getMaxPageCount
{
    return fz_count_pages(self.doc);
}

-(UIImage*)newImageWithPixmap:(fz_pixmap*)pix
{
	unsigned char *samples = fz_pixmap_samples(_ctx, pix);
	int w = fz_pixmap_width(_ctx, pix);
	int h = fz_pixmap_height(_ctx, pix);
	CGDataProviderRef cgdata = CGDataProviderCreateWithData(pix, samples, w * 4 * h, releasePixmap);
	CGColorSpaceRef cgcolor = CGColorSpaceCreateDeviceRGB();
	CGImageRef cgimage = CGImageCreate(w, h, 8, 32, 4 * w,
                                       cgcolor, kCGBitmapByteOrderDefault,
                                       cgdata, NULL, NO, kCGRenderingIntentDefault);
	UIImage *image = [[UIImage alloc]
                      initWithCGImage: cgimage
                      scale: _screenScale
                      orientation: UIImageOrientationUp];
	CGDataProviderRelease(cgdata);
	CGColorSpaceRelease(cgcolor);
	CGImageRelease(cgimage);
	return image;
}

+(CGSize)fitPageToScreen:(CGSize)page screenSize:(CGSize)screen
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
	CGSize pageSize;
	fz_rect bounds;
	fz_bound_page(_doc, page, &bounds);
	pageSize.width = bounds.x1 - bounds.x0;
	pageSize.height = bounds.y1 - bounds.y0;
	return pageSize;
}

-(UIImage*)renderPage:(fz_page*)page screenSize:(CGSize)screenSize
{
	CGSize pageSize;
	fz_irect bbox;
	fz_matrix ctm;
	fz_device *dev;
	fz_pixmap *pix;
	CGSize scale;
    
	screenSize.width *= _screenScale;
	screenSize.height *= _screenScale;
    
	pageSize = [self measurePage:page];
	scale = [CFZ_Administrator fitPageToScreen:pageSize screenSize:screenSize];
	fz_scale(&ctm, scale.width, scale.height);
	bbox = (fz_irect){0, 0, pageSize.width * scale.width, pageSize.height * scale.height};
    
	pix = fz_new_pixmap_with_bbox(_ctx, fz_device_rgb, &bbox);
	fz_clear_pixmap_with_value(_ctx, pix, 255);
    
	dev = fz_new_draw_device(_ctx, pix);
	fz_run_page(_doc, page, dev, &ctm, NULL);
	fz_free_device(dev);
    
	return [self newImageWithPixmap:pix];
}

-(UIImage *)renderTile:(fz_page*)page screenSize:(CGSize)screenSize tileRect:(CGRect)tileRect zoom:(float)zoom
{
	CGSize pageSize;
	fz_irect bbox;
	fz_matrix ctm;
	fz_device *dev;
	fz_pixmap *pix;
	CGSize scale;
    
	screenSize.width *= _screenScale;
	screenSize.height *= _screenScale;
	tileRect.origin.x *= _screenScale;
	tileRect.origin.y *= _screenScale;
	tileRect.size.width *= _screenScale;
	tileRect.size.height *= _screenScale;
    
	pageSize = [self measurePage:page];
	scale = [CFZ_Administrator fitPageToScreen:pageSize screenSize:screenSize];
	fz_scale(&ctm, scale.width * zoom, scale.height * zoom);
    
	bbox.x0 = tileRect.origin.x;
	bbox.y0 = tileRect.origin.y;
	bbox.x1 = tileRect.origin.x + tileRect.size.width;
	bbox.y1 = tileRect.origin.y + tileRect.size.height;
    
	pix = fz_new_pixmap_with_bbox(_ctx, fz_device_rgb, &bbox);
	fz_clear_pixmap_with_value(_ctx, pix, 255);
    
	dev = fz_new_draw_device(_ctx, pix);
	fz_run_page(_doc, page, dev, &ctm, NULL);
	fz_free_device(dev);
    
	return [self newImageWithPixmap:pix];
}

#pragma mark 显示pdf文件
-(NSMutableArray*)showPdfFiles
{
    char filename[PATH_MAX];
    strcpy(filename, [NSHomeDirectory() UTF8String]);
	strcat(filename, "/Documents/");
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    return array;
}

#pragma mark 打开pdf
- (void) openDocument: (NSString*)nsfilename
{
	char filename[PATH_MAX];
    
	dispatch_sync(_queue, ^{});
    
	strcpy(filename, [NSHomeDirectory() UTF8String]);
	strcat(filename, "/Documents/");
	strcat(filename, [nsfilename UTF8String]);
    
	_doc = fz_open_document(_ctx, filename);
	if (!_doc) {
		return;
	}
    
	if (fz_needs_password(_doc))
    {
        NSLog(@"pdf have password!!!");
    }
    else {
        self.curDocumentFileName = [NSString stringWithFormat:@"%@",nsfilename];
        self.curDocumentFilePath = [NSString stringWithFormat:@"%s",filename];
    }
}


#pragma mark 初始化当前页面的词信息
-(void) initCurPageData
{
    /*
    fz_page *page = fz_load_page(_doc, _curPageIndex);
	fz_text_sheet *sheet = fz_new_text_sheet(_ctx);
	fz_text_page *text = fz_new_text_page(_ctx, &fz_empty_rect);
	fz_device *dev = fz_new_text_device(_ctx, sheet, text);
	fz_run_page(_doc, page, dev, &fz_identity, NULL);
	fz_free_device(dev);
    [_pageOfWordsArray removeAllObjects];
    int pageWordCount = textlen(text);
    int curWordIndex = 0;
    int orgn = curWordIndex;
    NSMutableString *word = [NSMutableString stringWithCapacity:0];
    for (int pos = curWordIndex; pos < pageWordCount; pos++) {
        char c = charat(text, pos);
        if (c == ' ') {
            if (word.length) {
                fz_rect wordRect = [self getWordRectForTextPage:text beginIndex:orgn endIndex:pos];
                FZWordInfoObj *fzObj = [[FZWordInfoObj alloc] init];
                fzObj.text = word;
                fzObj.rect = wordRect;
                fzObj.charLength = orgn-pos;
                [_pageOfWordsArray addObject:fzObj];
                SafeRelease(fzObj);
                word = [NSMutableString stringWithCapacity:0];
            }
            
            curWordIndex = pos+1;
            orgn = pos;
        }
        else {
            [word appendFormat:@"%c",c];
        }
    }
    _curPageWordCount = _pageOfWordsArray.count;
    
    fz_free_text_page(_ctx, text);
	fz_free_text_sheet(_ctx, sheet);
	fz_free_page(_doc, page);

    static fz_text_char emptychar = { {0,0,0,0}, ' ' };
	fz_text_block *block;
	fz_text_line *line;
	fz_text_span *span;
	int ofs = 0;
	for (block = page->blocks; block < page->blocks + page->len; block++)
	{
		for (line = block->lines; line < block->lines + block->len; line++)
		{
			for (span = line->spans; span < line->spans + line->len; span++)
			{
				if (idx < ofs + span->len)
					return span->text[idx - ofs];
				//pseudo-newline
				if (span + 1 == line->spans + line->len)
				{
					if (idx == ofs + span->len)
						return emptychar;
					ofs++;
				}
				ofs += span->len;
			}
		}
	}
	return emptychar;
     */
}

#pragma mark 返回字符串的rect
-(fz_rect) getWordRectForSpan:(fz_text_span*) span beginIndex:(int)begin endIndex:(int)end
{
    fz_rect resRect = fz_empty_rect;
    for (int i = begin; i < end; i++)
    {
        fz_rect charbox = span->text[i].bbox;
        if (!fz_is_empty_rect(&charbox))
        {
            fz_union_rect(&resRect, &charbox);
        }
    }
    
    return resRect;
}

#pragma mark 返回字符串的rect
-(fz_rect) getWordRectForTextPage:(fz_text_page*) text beginIndex:(int)begin endIndex:(int)end
{
    fz_rect resRect = fz_empty_rect;
    for (int i = begin; i < end; i++)
    {
        fz_rect charbox;
        bboxat(text, i, &charbox);
        if (!fz_is_empty_rect(&charbox))
        {
            if (charbox.y0 != resRect.y0 || fz_abs(charbox.x0 - resRect.x1) > 5)
            {
                resRect = charbox;
            }
            else
            {
                fz_union_rect(&resRect, &charbox);
            }
        }
    }
    
    return resRect;
}

#pragma mark 返回某页某个单词0上1左2下3右
-(NSString*)searchWord:(NSInteger)direction
{
    
    NSString *res = nil;

    fz_page *page = fz_load_page(_doc, _curPageIndex);
    
	fz_text_sheet *sheet = fz_new_text_sheet(_ctx);
	fz_text_page *text = fz_new_text_page(_ctx, &fz_empty_rect);
	fz_device *dev = fz_new_text_device(_ctx, sheet, text);
	fz_run_page(_doc, page, dev, &fz_identity, NULL);
	fz_free_device(dev);
    
    res = [self getSelectWordForTextPage:text direction:direction];
    
    fz_free_text_page(_ctx, text);
	fz_free_text_sheet(_ctx, sheet);
	fz_free_page(_doc, page);

    return  res;
}

-(NSString*) getSelectWordForTextPage:(fz_text_page *)page direction:(NSInteger)direction
{
    if (direction < 0 || direction > 3) {
        return nil;
    }
    
    fz_text_block *block;
	fz_text_line *line; 
	fz_text_span *span = nil;
    NSInteger charIndex = -1;
    NSInteger spanIndex = -1;
    NSInteger curSpanIndex = 0;
    
    if (_searchWordObj) {
        NSArray *array = [self getSearchWordIndexForDirection:direction];
        spanIndex = [[array objectAtIndex:0] integerValue];
        charIndex = [[array objectAtIndex:1] integerValue];
    }
    else {
        spanIndex = 0;
        charIndex = 0;
    }
    
    if (charIndex >= 0 && spanIndex >= 0) {
        for (block = page->blocks; block < page->blocks + page->len; block++)
        {
            for (line = block->lines; line < block->lines + block->len; line++)
            {
                for (span = line->spans; span < line->spans + line->len; span++)
                {
                    if (curSpanIndex == spanIndex) {
                        const char *buf = nil;
                        NSArray *resArray = [self matchWordForSpan:span getContent:&buf pos:charIndex];
                        if (resArray.count) {
                            NSString *word = [NSString stringWithUTF8String:buf];
                            free((void*)buf);
                            NSInteger beginIndex = [[resArray objectAtIndex:0] integerValue];
                            NSInteger endIndex = [[resArray objectAtIndex:1] integerValue];
                            fz_rect wordRect = [self getWordRectForSpan:span beginIndex:beginIndex endIndex:endIndex];
                            FZWordInfoObj *obj = [[FZWordInfoObj alloc] init];
                            NSString *text = [word lowercaseString];
                            text = [CFZ_Administrator getNSCharactersetWithNSString:text];
                            obj.text = text;
                            obj.rect = wordRect;
                            obj.charLength = endIndex - beginIndex;
                            obj.spanIndex = curSpanIndex;
                            obj.charIndex = beginIndex;
                            self.searchWordObj = obj;
                            SafeRelease(obj);
                            return self.searchWordObj.text;
                        }
                    }
                    curSpanIndex++;
                }
            }
        }
    }
    
	return nil;
}

-(NSArray*) getSearchWordIndexForDirection:(NSInteger)direction
{
    NSInteger spanIndex = _searchWordObj.spanIndex;
    NSInteger charIndex = _searchWordObj.charIndex;
    if (direction == 0) {
        spanIndex--;
        charIndex = charIndex+_searchWordObj.charLength/2;
    }
    else if (direction == 1)
    {
        charIndex = charIndex-2;
    }
    else if (direction == 2)
    {
        spanIndex++;
        charIndex = charIndex+_searchWordObj.charLength/2;
    }
    else if (direction == 3)
    {
        charIndex = charIndex + _searchWordObj.charLength+1;
    }
    
    return [NSArray arrayWithObjects:[NSNumber numberWithInteger:spanIndex],[NSNumber numberWithInteger:charIndex], nil];
}

-(NSArray*) matchWordForSpan:(fz_text_span *)span getContent:(const char **)s pos:(NSInteger)n
{
    NSArray *resArray = nil;
    char ss = ' ';
    int beginIndex = 0;
    int endIndex = 0;
    
    if (span->len < 3) {
        n = 0;
    }
    else {
        if (n > span->len-2) {
            n = span->len - 2;//(n<span->len?span->len-n:2);
        }
    }
    
    
    do {
        if (n < span->len && n >= 0) {
            ss = span->text[n].c;
            if (ss == ' ') {
                n++;
                beginIndex = n;
                break;
            }
        }
        if (n == 0) {
            beginIndex = n;
            break;
        }
        n--;
    } while (1);
    
    do {
        if (n < span->len && n >= 0) {
            ss = span->text[n].c;
            if (ss == ' ') {
                break;
            }
        }
        if (n == span->len) {
            break;
        }
        n++;
    } while (1);
    endIndex = n;
    
    if (beginIndex < endIndex) {
        NSInteger res = endIndex-beginIndex;
        char *buf = malloc(res+1);
        char *gapBuf = buf;
        memset(buf, 0, res+1);
        for (int i = beginIndex; i < endIndex; i++) {
            *gapBuf = span->text[i].c;
            gapBuf++;
        }
        *s = buf;
        resArray = [NSArray arrayWithObjects:[NSNumber numberWithInteger:beginIndex],[NSNumber numberWithInteger:endIndex], nil];
    }
    
	return resArray;
}

-(void)removeDataArrayAllObj
{
    [_dataArray removeAllObjects];
}

-(void)removeUnDataArrayAllObj
{
    [_unDataArray removeAllObjects];
}

#pragma mark 加入有数据单词逻辑
-(BOOL) addHasDataWordLogic:(CWordObj*)obj
{
    BOOL res = NO;
//    CWordObj *otherObj = [_DB getWordFromDBWithWordName:obj.ENContent];
//    if (otherObj) {
//        otherObj.clickCount += obj.clickCount;
//        [_DB updateWordInfoToCommitListWithWordObj:otherObj];
//    }
//    else {
//        otherObj = obj;
//        res = [_DB addWordToCommitListWithWordObj:otherObj];
//    }
//    
//    if (res) {
//        for (CWordObj *arrayObj in _dataArray) {
//            if ([arrayObj.ENContent isEqualToString:otherObj.ENContent]) {
//                [_dataArray removeObject:arrayObj];
//                break;
//            }
//        }
//        [_dataArray addObject:otherObj];
//    }
    
    return res;
}

#pragma mark 返回有数据的单词
-(CWordObj*) getWordFromCommitListWithName:(NSString*)name
{
    CWordObj *resObj = nil;
    
//    for (CWordObj *obj in _dataArray) {
//        if ([obj.ENContent isEqualToString:name]) {
//            resObj = obj;
//            break;
//        }
//    }
//    
//    if (!resObj) {
//        resObj = [_DB getWordFromDBWithWordName:name];
//        if (resObj) {
//            [_dataArray addObject:resObj];
//        }
//    }
    
    return resObj;
}

#pragma mark 返回没有数据的单词
-(CWordObj*) getWordFromUNCommitListWithName:(NSString*)name
{
    CWordObj *resObj = nil;
    
    for (CWordObj *obj in _unDataArray) {
        if ([obj.ENContent isEqualToString:name]) {
            resObj = obj;
            break;
        }
    }
    
    if (!resObj) {
        resObj = [_DB getWordFromUnCommitListWithWordName:name];
        if (resObj) {
            [_unDataArray addObject:resObj];
        }
    }
    
    return resObj;
}

#pragma mark 返回没有数据的单词个数
-(NSInteger) getWordCountFromUNCommitList
{
    return 0;//[_DB getWordCountFromUnCommitList];
}

#pragma mark 读取未提交的单词到数组中
-(void) getWordsFromUNCommitListToUnDataArray
{
//    [_DB getWordsFromUNCommitListToArray:_unDataArray];
}

#pragma mark 加入没有数据的单词逻辑
-(BOOL) addUnHasDataWordLogic:(CWordObj*)obj
{
    BOOL res = NO;
    
//    CWordObj *otherObj = [_DB getWordFromUnCommitListWithWordName:obj.ENContent];
//    if (otherObj) {
//        otherObj.clickCount += obj.clickCount;
//        res = [_DB updateWordInfoToUNCommitListWithWordObj:otherObj];
//    }
//    else {
//        res = [_DB addWordToUNCommitListWithWordObj:obj];
//        otherObj = obj;
//    }
//    
//    if (res) {
//        for (CWordObj *arrayObj in _unDataArray) {
//            if ([arrayObj.ENContent isEqualToString:otherObj.ENContent]) {
//                [_unDataArray removeObject:arrayObj];
//                break;
//            }
//        }
//        
//        [_unDataArray addObject:otherObj];
//    }
    
    return res;
}

#pragma mark 删除未提交的数据
-(void)deleteUnCommitWord:(CWordObj*)obj
{
    for (CWordObj *arrayObj in _unDataArray) {
        if ([arrayObj.ENContent isEqualToString:obj.ENContent]) {
            [_unDataArray removeObject:arrayObj];
            break;
        }
    }
    
//    [_DB deleteWordFromUNCommitListWithWordName:obj.ENContent];
}

#pragma mark 查找索引的数据
-(NSMutableArray*) selectWordObjFromCommitListWithCount:(NSInteger)count
{
    NSMutableArray *resArray = [[NSMutableArray alloc] initWithCapacity:0];
    [_DB selectWordWithIndex:_curSelectWordIndex count:count toArray:resArray];
    if (resArray.count) {
        _curSelectWordIndex += resArray.count;
    }
    return resArray;
}

-(fz_rect)search_result_bbox:(NSInteger)i
{
	return _hit_bbox[i];
}

@end

@implementation MuHitView

- (id) initWithSearchResults: (int)n forDocument: (fz_document *)doc
{
	self = [super initWithFrame: CGRectMake(0,0,100,100)];
	if (self) {
		[self setOpaque: NO];
        
		color = [UIColor colorWithRed: 0x25/255.0 green: 0x72/255.0 blue: 0xAC/255.0 alpha: 0.5];
        
		pageSize = CGSizeMake(100,100);
        
		for (int i = 0; i < n && i < nelem(hitRects); i++) {
			fz_rect bbox = [[CFZ_Administrator shareInstance] search_result_bbox:i]; // this is thread-safe enough
			hitRects[i].origin.x = bbox.x0;
			hitRects[i].origin.y = bbox.y0;
			hitRects[i].size.width = bbox.x1 - bbox.x0;
			hitRects[i].size.height = bbox.y1 - bbox.y0;
		}
		hitCount = n;
	}
	return self;
}

- (id) initWithSearchRect:(fz_rect*)rect forDocument:(fz_document *)doc
{
    self = [super initWithFrame: CGRectMake(0,0,100,100)];
	if (self) {
		[self setOpaque: NO];
        
		color = [UIColor colorWithRed: 0x25/255.0 green: 0x72/255.0 blue: 0xAC/255.0 alpha: 0.5];
        
		pageSize = CGSizeMake(100,100);
        
        /*
		for (int i = 0; i < n && i < nelem(hitRects); i++) {
			fz_rect bbox = [[CFZ_Administrator shareInstance] search_result_bbox:i]; // this is thread-safe enough
			hitRects[i].origin.x = bbox.x0;
			hitRects[i].origin.y = bbox.y0;
			hitRects[i].size.width = bbox.x1 - bbox.x0;
			hitRects[i].size.height = bbox.y1 - bbox.y0;
		}
		hitCount = n;
         */
        fz_rect bbox = [CFZ_Administrator shareInstance].searchWordObj.rect;
        hitRects[0].origin.x = bbox.x0;
        hitRects[0].origin.y = bbox.y0;
        hitRects[0].size.width = bbox.x1 - bbox.x0;
        hitRects[0].size.height = bbox.y1 - bbox.y0;
        hitCount = 1;
	}
	return self;
}

- (id) initWithLinks: (fz_link*)link forDocument: (fz_document *)doc
{
	self = [super initWithFrame: CGRectMake(0,0,100,100)];
	if (self) {
		[self setOpaque: NO];
        
		color = [UIColor colorWithRed: 0xAC/255.0 green: 0x72/255.0 blue: 0x25/255.0 alpha: 0.5];
        
		pageSize = CGSizeMake(100,100);
        
		while (link && hitCount < nelem(hitRects)) {
			if (link->dest.kind == FZ_LINK_GOTO || link->dest.kind == FZ_LINK_URI) {
				fz_rect bbox = link->rect;
				hitRects[hitCount].origin.x = bbox.x0;
				hitRects[hitCount].origin.y = bbox.y0;
				hitRects[hitCount].size.width = bbox.x1 - bbox.x0;
				hitRects[hitCount].size.height = bbox.y1 - bbox.y0;
				linkPage[hitCount] = link->dest.kind == FZ_LINK_GOTO ? link->dest.ld.gotor.page : -1;
				linkUrl[hitCount] = link->dest.kind == FZ_LINK_URI ? strdup(link->dest.ld.uri.uri) : nil;
				hitCount++;
			}
			link = link->next;
		}
	}
	return self;
}

- (void) setPageSize: (CGSize)s
{
	pageSize = s;
	// if page takes a long time to load we may have drawn at the initial (wrong) size
	[self setNeedsDisplay];
}

- (void) drawRect: (CGRect)r
{
	CGSize scale = [CFZ_Administrator fitPageToScreen:pageSize screenSize:self.bounds.size];
    
	[color set];
    
	for (int i = 0; i < hitCount; i++) {
		CGRect rect = hitRects[i];
		rect.origin.x *= scale.width;
		rect.origin.y *= scale.height;
		rect.size.width *= scale.width;
		rect.size.height *= scale.height;
		UIRectFill(rect);
	}
}

- (void) dealloc
{
	for (int i = 0; i < hitCount; i++)
		free(linkUrl[i]);
}

@end

@implementation MuPageView

- (id) initWithFrame: (CGRect)frame document: (fz_document*)aDoc page: (int)aNumber
{
	self = [super initWithFrame: frame];
	if (self) {
		doc = aDoc;
		number = aNumber;
		cancel = NO;
        
		[self setShowsVerticalScrollIndicator: NO];
		[self setShowsHorizontalScrollIndicator: NO];
		[self setDecelerationRate: UIScrollViewDecelerationRateFast];
		[self setDelegate: self];
        
		// zoomDidFinish/Begin events fire before bounce animation completes,
		// making a mess when we rearrange views during the animation.
		[self setBouncesZoom: NO];
        
		[self resetZoomAnimated: NO];
        
		// TODO: use a one shot timer to delay the display of this?
		loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[loadingView startAnimating];
		[self addSubview: loadingView];
        
		[self loadPage];
	}
	return self;
}

- (void) dealloc
{
	// dealloc can trigger in background thread when the queued block is
	// our last owner, and releases us on completion.
	// Send the dealloc back to the main thread so we don't mess up UIKit.
	if (dispatch_get_current_queue() != dispatch_get_main_queue()) {
		__block id block_self = self; // don't auto-retain self!
		dispatch_async(dispatch_get_main_queue(), ^{ [block_self dealloc]; });
	} else {
		__block fz_page *block_page = page;
		__block fz_document *block_doc = doc;
		dispatch_async([CFZ_Administrator shareInstance].queue, ^{
			if (block_page)
				fz_free_page(block_doc, block_page);
			block_page = nil;
		});
		[linkView release];
		[hitView release];
		[tileView release];
		[loadingView release];
		[imageView release];
		[super dealloc];
	}
}

- (int) number
{
	return number;
}

- (void) showLinks
{
	if (!linkView) {
		dispatch_async([CFZ_Administrator shareInstance].queue, ^{
			if (!page)
				page = fz_load_page(doc, number);
			fz_link *links = fz_load_links(doc, page);
			dispatch_async(dispatch_get_main_queue(), ^{
				linkView = [[MuHitView alloc] initWithLinks: links forDocument: doc];
				dispatch_async([CFZ_Administrator shareInstance].queue, ^{
//					fz_drop_link(ctx, links);
				});
				if (imageView) {
					[linkView setFrame: [imageView frame]];
					[linkView setPageSize: pageSize];
				}
				[self addSubview: linkView];
			});
		});
	}
}

- (void) hideLinks
{
	[linkView removeFromSuperview];
	[linkView release];
	linkView = nil;
}

- (void) showSearchResults: (int)count
{
	if (hitView) {
		[hitView removeFromSuperview];
		[hitView release];
		hitView = nil;
	}
	hitView = [[MuHitView alloc] initWithSearchResults: count forDocument: doc];
	if (imageView) {
		[hitView setFrame: [imageView frame]];
		[hitView setPageSize: pageSize];
	}
	[self addSubview: hitView];
}

- (void) showSearchResultsWithRect:(fz_rect)rect
{
	if (hitView) {
		[hitView removeFromSuperview];
		[hitView release];
		hitView = nil;
	}
	hitView = [[MuHitView alloc] initWithSearchRect:&rect forDocument: doc];
	if (imageView) {
		[hitView setFrame: [imageView frame]];
		[hitView setPageSize: pageSize];
	}
	[self addSubview: hitView];
}

- (void) clearSearchResults
{
	if (hitView) {
		[hitView removeFromSuperview];
		[hitView release];
		hitView = nil;
	}
}

- (void) resetZoomAnimated: (BOOL)animated
{
	// discard tile and any pending tile jobs
	tileFrame = CGRectZero;
	tileScale = 1;
	if (tileView) {
		[tileView removeFromSuperview];
		[tileView release];
		tileView = nil;
	}
    
	[self setMinimumZoomScale: 1];
	[self setMaximumZoomScale: 5];
	[self setZoomScale: 1 animated: animated];
}

- (void) removeFromSuperview
{
	cancel = YES;
	[super removeFromSuperview];
}

- (void) loadPage
{
	if (number < 0 || number >= fz_count_pages(doc))
		return;
	dispatch_async([CFZ_Administrator shareInstance].queue, ^{
		if (!cancel) {
			printf("render page %d\n", number);
			if (!page)
				page = fz_load_page(doc, number);
			CGSize size = [[CFZ_Administrator shareInstance] measurePage:page];
			UIImage *image = [[CFZ_Administrator shareInstance] renderPage:page screenSize:self.bounds.size];
			dispatch_async(dispatch_get_main_queue(), ^{
				pageSize = size;
				[self displayImage: image];
				[image release];
			});
		} else {
			printf("cancel page %d\n", number);
		}
	});
}

- (void) displayImage: (UIImage*)image
{
	if (loadingView) {
		[loadingView removeFromSuperview];
		[loadingView release];
		loadingView = nil;
	}
    
	if (hitView)
		[hitView setPageSize: pageSize];
    
	if (!imageView) {
		imageView = [[UIImageView alloc] initWithImage: image];
		imageView.opaque = YES;
		[self addSubview: imageView];
		if (hitView)
			[self bringSubviewToFront: hitView];
	} else {
		[imageView setImage: image];
	}
    
	[self resizeImage];
}

- (void) resizeImage
{
	if (imageView) {
		CGSize imageSize = imageView.image.size;
		CGSize scale = [CFZ_Administrator fitPageToScreen:imageSize screenSize:self.bounds.size];
		if (fabs(scale.width - 1) > 0.1) {
			CGRect frame = [imageView frame];
			frame.size.width = imageSize.width * scale.width;
			frame.size.height = imageSize.height * scale.height;
			[imageView setFrame: frame];
            
			printf("resized view; queuing up a reload (%d)\n", number);
			dispatch_async([CFZ_Administrator shareInstance].queue, ^{
				dispatch_async(dispatch_get_main_queue(), ^{
					CGSize scale = [CFZ_Administrator fitPageToScreen:imageView.image.size screenSize:self.bounds.size];
					if (fabs(scale.width - 1) > 0.01)
						[self loadPage];
				});
			});
		} else {
			[imageView sizeToFit];
		}
        
		[self setContentSize: imageView.frame.size];
        
		[self layoutIfNeeded];
	}
    
}

- (void) willRotate
{
	if (imageView) {
		[self resetZoomAnimated: NO];
		[self resizeImage];
	}
}

- (void) layoutSubviews
{
	[super layoutSubviews];
    
	// center the image as it becomes smaller than the size of the screen
    
	CGSize boundsSize = self.bounds.size;
	CGRect frameToCenter = loadingView ? loadingView.frame : imageView.frame;
    
	// center horizontally
	if (frameToCenter.size.width < boundsSize.width)
		frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2);
	else
		frameToCenter.origin.x = 0;
    
	// center vertically
	if (frameToCenter.size.height < boundsSize.height)
		frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2);
	else
		frameToCenter.origin.y = 0;
    
	if (loadingView)
		loadingView.frame = frameToCenter;
	else
		imageView.frame = frameToCenter;
    
	if (hitView && imageView)
		[hitView setFrame: [imageView frame]];
}

- (UIView*) viewForZoomingInScrollView: (UIScrollView*)scrollView
{
	return imageView;
}

- (void) loadTile
{
	CGSize screenSize = self.bounds.size;
    
	tileFrame.origin = self.contentOffset;
	tileFrame.size = self.bounds.size;
	tileFrame = CGRectIntersection(tileFrame, imageView.frame);
	tileScale = self.zoomScale;
    
	CGRect frame = tileFrame;
	float scale = tileScale;
    
	CGRect viewFrame = frame;
	if (self.contentOffset.x < imageView.frame.origin.x)
		viewFrame.origin.x = 0;
	if (self.contentOffset.y < imageView.frame.origin.y)
		viewFrame.origin.y = 0;
    
	if (scale < 1.01)
		return;
    
	dispatch_async([CFZ_Administrator shareInstance].queue, ^{
		__block BOOL isValid;
		dispatch_sync(dispatch_get_main_queue(), ^{
			isValid = CGRectEqualToRect(frame, tileFrame) && scale == tileScale;
		});
		if (!isValid) {
			printf("cancel tile\n");
			return;
		}
        
		if (!page)
			page = fz_load_page(doc, number);
        
		printf("render tile\n");
		UIImage *image = [[CFZ_Administrator shareInstance] renderTile:page screenSize:screenSize tileRect:viewFrame zoom:scale];
        
		dispatch_async(dispatch_get_main_queue(), ^{
			isValid = CGRectEqualToRect(frame, tileFrame) && scale == tileScale;
			if (isValid) {
				tileFrame = CGRectZero;
				tileScale = 1;
				if (tileView) {
					[tileView removeFromSuperview];
					[tileView release];
					tileView = nil;
				}
                
				tileView = [[UIImageView alloc] initWithFrame: frame];
				[tileView setImage: image];
				[self addSubview: tileView];
				if (hitView)
					[self bringSubviewToFront: hitView];
			} else {
				printf("discard tile\n");
			}
			[image release];
		});
	});
}

- (void) scrollViewDidScrollToTop:(UIScrollView *)scrollView { [self loadTile]; }
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView { [self loadTile]; }
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView { [self loadTile]; }
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate)
		[self loadTile];
}

- (void) scrollViewWillBeginZooming: (UIScrollView*)scrollView withView: (UIView*)view
{
	// discard tile and any pending tile jobs
	tileFrame = CGRectZero;
	tileScale = 1;
	if (tileView) {
		[tileView removeFromSuperview];
		[tileView release];
		tileView = nil;
	}
}

- (void) scrollViewDidEndZooming: (UIScrollView*)scrollView withView: (UIView*)view atScale: (float)scale
{
	[self loadTile];
}

- (void) scrollViewDidZoom: (UIScrollView*)scrollView
{
	if (hitView && imageView)
		[hitView setFrame: [imageView frame]];
}

@end
