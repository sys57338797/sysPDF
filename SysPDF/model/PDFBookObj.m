//
//  CBookObj.m
//  MuPDF
//
//  Created by mutouren on 8/20/13.
//
//

#import "PDFBookObj.h"

@implementation PDFBookObj

+ (id)createBookObjWithPath:(NSString*)path name:(NSString*)name
{
    PDFBookObj *obj = [[PDFBookObj alloc] init];
    obj.bookPath = path;
    obj.bookName = name;
    obj.maxPage = 0;
    obj.currentPage = 0;
    
    return obj;
}


@end
