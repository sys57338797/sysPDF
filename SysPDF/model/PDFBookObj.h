//
//  CBookObj.h
//  MuPDF
//
//  Created by mutouren on 8/20/13.
//
//

#import <Foundation/Foundation.h>

@interface PDFBookObj : NSObject

@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign) NSInteger maxPage;
@property (nonatomic, copy) NSString *bookName;
@property (nonatomic, copy) NSString *bookPath;


+ (id)createBookObjWithPath:(NSString*)path name:(NSString*)name;

@end
