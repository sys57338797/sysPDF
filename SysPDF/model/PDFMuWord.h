


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>





@interface PDFMuWord : NSObject

@property (nonatomic, copy) NSMutableString *string;
@property (nonatomic, assign) CGRect rect;


+ (PDFMuWord *) word;
- (void) appendChar:(unichar)c withRect:(CGRect)rect;
+ (void) selectFrom:(CGPoint)pt1 to:(CGPoint)pt2 fromWords:(NSArray *)words onStartLine:(void (^)(void))startBlock onWord:(void (^)(PDFMuWord *))wordBlock onEndLine:(void (^)(void))endBLock;
@end
