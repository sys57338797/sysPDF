

#import <UIKit/UIKit.h>




@interface PDFMuTextSelectView : UIView
- (id) initWithWords:(NSArray *)_words pageSize:(CGSize)_pageSize;
- (NSArray *) selectionRects;
- (NSString *) selectedText;
@end
