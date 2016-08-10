


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>





@interface PDFMuWord : NSObject

@property (nonatomic, copy, readonly) NSMutableString *content;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) CGRect secondRect;


+ (PDFMuWord *) word;
- (void) appendChar:(unichar)c withRect:(CGRect)rect atRect:(CGRect)atRect;
+ (void) selectFromPoint:(CGPoint)pt fromWords:(NSArray *)words onFinish:(void (^)(PDFMuWord *))finishBlock;
+ (void) selectFrom:(CGPoint)pt1 to:(CGPoint)pt2 fromWords:(NSArray *)words onStartLine:(void (^)(void))startBlock onWord:(void (^)(PDFMuWord *))wordBlock onEndLine:(void (^)(void))endBLock;
@end
