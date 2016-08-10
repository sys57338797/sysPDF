
#import "PDFMuTextSelectView.h"
#import "PDFMuWord.h"
#import "PDFManager.h"

@implementation PDFMuTextSelectView
{
	NSArray *words;
	CGSize pageSize;
	UIColor *color;
	CGPoint start;
	CGPoint end;
    CGPoint selectPoint;
}

- (id) initWithWords:(NSArray *)_words pageSize:(CGSize)_pageSize start:(CGPoint)s end:(CGPoint)e
{
    self = [self initWithWords:_words pageSize:_pageSize];
    if (self) {
        start = s;
        end = e;
        
        [self setNeedsDisplay];
    }
    
    return self;
}

- (id) initWithWords:(NSArray *)_words pageSize:(CGSize)_pageSize
{
	self = [super initWithFrame:CGRectMake(0,0,100,100)];
	if (self)
	{
		[self setOpaque:NO];
		words = [_words copy];
		pageSize = _pageSize;
		color = [UIColor colorWithRed:0x25/255.0 green:0x72/255.0 blue:0xAC/255.0 alpha:0.5];
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
        [singleTapGestureRecognizer setNumberOfTapsRequired:1];
        [self addGestureRecognizer:singleTapGestureRecognizer];
        
	}
	return self;
}

- (NSArray *) selectionRects
{
	NSMutableArray *arr = [NSMutableArray array];
	__block CGRect r;

	[PDFMuWord selectFrom:start to:end fromWords:words
		onStartLine:^{
			r = CGRectNull;
		} onWord:^(PDFMuWord *w) {
			r = CGRectUnion(r, w.rect);
		} onEndLine:^{
			if (!CGRectIsNull(r))
				[arr addObject:[NSValue valueWithCGRect:r]];
		}];

	return arr;
}

- (NSString *) selectedText
{
	__block NSMutableString *text = [NSMutableString string];
	__block NSMutableString *line;

	[PDFMuWord selectFrom:start to:end fromWords:words
		onStartLine:^{
			line = [NSMutableString string];
		} onWord:^(PDFMuWord *w) {
			if (line.length > 0)
				[line appendString:@" "];
			[line appendString:w.content];
		} onEndLine:^{
			if (text.length > 0)
				[text appendString:@"\n"];
			[text appendString:line];
		}];

	return text;
}

- (void)onTap:(UIGestureRecognizer*)sender
{
    CGSize scale = [[PDFManager shareInstance] fitPageToScreen:pageSize screenSize:self.bounds.size];
    CGPoint p = [sender locationInView:self];
    p.x /= scale.width;
    p.y /= scale.height;

    selectPoint = p;
    
    [self setNeedsDisplay];
}

//-(void) onDrag:(UIPanGestureRecognizer *)rec
//{
//    CGSize scale = [[PDFManager shareInstance] fitPageToScreen:pageSize screenSize:self.bounds.size];
//	CGPoint p = [rec locationInView:self];
//	p.x /= scale.width;
//	p.y /= scale.height;
//
//	if (rec.state == UIGestureRecognizerStateBegan)
//		start = p;
//
//	end = p;
//
//	[self setNeedsDisplay];
//}

- (void) drawRect:(CGRect)rect
{
	CGSize scale = [[PDFManager shareInstance] fitPageToScreen:pageSize screenSize:self.bounds.size];
	CGContextRef cref = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(cref, scale.width, scale.height);
//	__block CGRect r;

	[color set];

    if (!CGPointEqualToPoint(selectPoint, CGPointZero)) {
        [PDFMuWord selectFromPoint:selectPoint fromWords:words onFinish:^(PDFMuWord *w) {
            if (!CGRectIsNull(w.rect)) {
                UIRectFill(w.rect);
            }
        }];
    }
    
//	[PDFMuWord selectFrom:start to:end fromWords:words
//		onStartLine:^{
//			r = CGRectNull;
//		} onWord:^(PDFMuWord *w) {
//			r = CGRectUnion(r, w.rect);
//		} onEndLine:^{
//			if (!CGRectIsNull(r))
//				UIRectFill(r);
//		}];
}

@end
