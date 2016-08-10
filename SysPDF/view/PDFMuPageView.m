//
//  PDFMuPageView.m
//  SysPDF
//
//  Created by mutouren on 4/12/16.
//  Copyright © 2016 suyushen. All rights reserved.
//

#import "PDFMuPageView.h"
#import "PDFManager.h"
#import "PDFMuTextSelectView.h"
#import "PureLayout.h"
#import "PDFMuWord.h"


@interface PDFMuPageView ()
{
    int _number;
    fz_document *_doc;
    fz_page *_page;
    fz_display_list *_page_list;
    fz_display_list *_annot_list;
    BOOL _cancel;
    CGSize _pageSize;
    CGRect _tileFrame;
    float _tileScale;
    
}


@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) UIImageView *tileView;
@property (nonatomic, strong) PDFMuTextSelectView *selectView;


@property (nonatomic, strong) NSArray *words;
@property (nonatomic, readonly) dispatch_queue_t queue;
@property (nonatomic, strong) UIView *tapView;
@property (nonatomic, strong) NSArray *autoSubViewConstraint;

@end

@implementation PDFMuPageView

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"PDFMuPageView init!!!");
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"PDFMuPageView dealloc!!!");
    
    __block fz_display_list *weak_page_list = _page_list;
    __block fz_display_list *weak_annot_list = _annot_list;
    __block fz_page *weak_page = _page;
    
    dispatch_async(_queue, ^{
        if (weak_page_list)
            fz_drop_display_list([PDFManager shareInstance].ctx, weak_page_list);
        if (weak_annot_list)
            fz_drop_display_list([PDFManager shareInstance].ctx, weak_annot_list);
        if (weak_page)
            fz_drop_page([PDFManager shareInstance].ctx, weak_page);
        weak_page = nil;
    });
    
}

-(id) initWithFrame:(CGRect)frame document:(fz_document *)doc page:(int)aNumber
{
    self = [super initWithFrame: frame];
    if (self) {
        _doc = doc;
        _number = aNumber;
        
        _queue = dispatch_queue_create("PDFMuPageView", NULL);
        _cancel = NO;
        
        [self addSubview:self.contentImageView];
        
        [self setShowsVerticalScrollIndicator: NO];
        [self setShowsHorizontalScrollIndicator: NO];
        
        [self setDecelerationRate:UIScrollViewDecelerationRateFast];
        [self setDelegate:self];
        
        // zoomDidFinish/Begin events fire before bounce animation completes,
        // making a mess when we rearrange views during the animation.
        [self setBouncesZoom:NO];
        
        [self resetZoomAnimated:NO];
        
//        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
//        [singleTapGestureRecognizer setNumberOfTapsRequired:1];
//        [self addGestureRecognizer:singleTapGestureRecognizer];
        
//        [self loadPage];
    }
    return self;
}

//- (void)onTap:(UIGestureRecognizer*)sender
//{
//    CGPoint selfPoint = [sender locationInView:sender.view];
//    CGPoint point = [sender locationInView:self.contentImageView];
//    NSLog(@"selfPpoint===>x:%f,y:%f///ppoint===>x:%f,y:%f",selfPoint.x,selfPoint.y,point.x,point.y);
//    
//}

- (void)initWords
{
    dispatch_async(self.queue, ^{
        [self ensurePageLoaded];
        self.words = [[PDFManager shareInstance] enumerateWords:_doc fz_page:_page];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.selectView = [[PDFMuTextSelectView alloc] initWithWords:self.words pageSize:_pageSize];
            if (self.contentImageView)
                [self.selectView setFrame:[self.contentImageView frame]];
            [self addSubview:self.selectView];
        });
    });
}

- (void)setContentSize:(CGSize)contentSize
{
    if (!CGSizeEqualToSize(contentSize, CGSizeZero)) {
        [super setContentSize:contentSize];
    }
    
}

- (void)setBounds:(CGRect)bounds
{
    if (!CGSizeEqualToSize(self.bounds.size, bounds.size)) {
        [self loadPage];
        [self initWords];
    }
    [super setBounds:bounds];
}

- (void)loadPage
{
    dispatch_async(self.queue, ^{
        if (!_cancel&&!self.contentImageView.image) {
            printf("render page %d\n", self.number);
            [self ensureDisplaylists];
            CGSize scale = [[PDFManager shareInstance] fitPageToScreen:_pageSize screenSize:self.bounds.size];
            CGRect rect = (CGRect){{0.0, 0.0},{_pageSize.width * scale.width, _pageSize.height * scale.height}};
            if (_page_list && _annot_list) {
                fz_pixmap *image_pix = [[PDFManager shareInstance] renderPixmap:_doc pageList:_page_list displayList:_annot_list pageSize:_pageSize screenSize:self.bounds.size tileRect:rect zoom:1.0f];
                if (image_pix) {
                    CGDataProviderRef imageData = [[PDFManager shareInstance] CreateWrappedPixmap:image_pix];
                    UIImage *image = [[PDFManager shareInstance] newImageWithPixmap:image_pix ref:imageData];
                    CGDataProviderRelease(imageData);
                    //            widgetRects = enumerateWidgetRects(doc, page);
                    //            [self loadAnnotations];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self displayImage:image];
                        });
                    }
                }
            }
        } else {
            printf("cancel page %d\n", self.number);
        }
    });
}

- (void)displayImage: (UIImage*)image
{
    
    [self.contentImageView setImage:image];
    
    [self resizeImage];
}

- (void)resizeImage
{
    CGSize imageSize = self.contentImageView.image.size;
    CGSize scale = [[PDFManager shareInstance] fitPageToScreen:imageSize screenSize:self.bounds.size];
    if (fabs(scale.width - 1) > 0.1) {
        CGRect frame = [self.contentImageView frame];
        frame.size.width = imageSize.width * scale.width;
        frame.size.height = imageSize.height * scale.height;
        [self.contentImageView setFrame:frame];
        
        printf("resized view; queuing up a reload (%d)\n", self.number);
        dispatch_async(self.queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                CGSize scale = [[PDFManager shareInstance] fitPageToScreen:self.contentImageView.image.size screenSize:self.bounds.size];
                if (fabs(scale.width - 1) > 0.01)
                {
                    [self.contentImageView setImage:nil];
                    [self loadPage];
                }
                
            });
        });
    }
    else {
        [self.contentImageView sizeToFit];
    }
    
    
    [self setContentSize:imageSize];
    self.contentImageView.frame = CGRectMake(0, 0, self.contentImageView.image.size.width, self.contentImageView.image.size.height);
    [self scrollViewDidZoom:self];
//    [self setNeedsUpdateConstraints];
//    [self updateConstraintsIfNeeded];
    
}

- (void)ensureDisplaylists
{
    [self ensurePageLoaded];
    if (!_page)
        return;
    
    if (!_page_list)
        _page_list = [[PDFManager shareInstance] create_page_list:_doc page:_page];
    
    if (!_annot_list)
        _annot_list = [[PDFManager shareInstance] create_annot_list:_doc page:_page];
}

- (void)ensurePageLoaded
{
    if (_page)
        return;
    
    _page = [[PDFManager shareInstance] managerLoadPage:_number];
    _pageSize = [[PDFManager shareInstance] measurePage:_page];
}

- (void)loadTile
{
    CGSize screenSize = self.bounds.size;
    
    _tileFrame.origin = self.contentOffset;
    _tileFrame.size = self.bounds.size;
    _tileFrame = CGRectIntersection(_tileFrame, self.contentImageView.frame);
    _tileScale = self.zoomScale;
    
    CGRect frame = _tileFrame;
    float scale = _tileScale;
    
    CGRect viewFrame = frame;
    // Adjust viewFrame to be relative to imageView's origin
    viewFrame.origin.x -= self.contentImageView.frame.origin.x;
    viewFrame.origin.y -= self.contentImageView.frame.origin.y;
    
    if (scale < 1.01)
        return;
    
    dispatch_async(self.queue, ^{
        __block BOOL isValid;
        __block CGRect blockTileFrame = _tileFrame;
        __block float blockTileScale = _tileScale;
        dispatch_sync(dispatch_get_main_queue(), ^{
            isValid = CGRectEqualToRect(frame, blockTileFrame) && scale == blockTileScale;
        });
        if (!isValid) {
            printf("cancel tile\n");
            return;
        }
        
        [self ensureDisplaylists];
        
        printf("render tile\n");
        if (_page_list && _annot_list) {
            fz_pixmap *tile_pix = [[PDFManager shareInstance] renderPixmap:_doc pageList:_page_list displayList:_annot_list pageSize:_pageSize screenSize:screenSize tileRect:viewFrame zoom:scale];
            CGDataProviderRef tileData = [[PDFManager shareInstance] CreateWrappedPixmap:tile_pix];
            UIImage *image = [[PDFManager shareInstance] newImageWithPixmap:tile_pix ref:tileData];
            CGDataProviderRelease(tileData);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                isValid = CGRectEqualToRect(frame, blockTileFrame) && scale == blockTileScale;
                if (isValid) {
                    if (_tileView) {
                        [_tileView removeFromSuperview];
                    }
                    
                    _tileView = [[UIImageView alloc] initWithFrame: frame];
                    [_tileView setBackgroundColor:[UIColor clearColor]];
                    [_tileView setImage:image];
                    [self addSubview:_tileView];
                    if (self.selectView)
                        [self bringSubviewToFront:self.selectView];
                } else {
                    printf("discard tile\n");
                }
            });
        }
    });
}

#pragma mark UIScrollViewDelegate
- (void) scrollViewDidZoom: (UIScrollView*)scrollView
{
    if (self.contentImageView)
    {
        CGRect frm = [self.contentImageView frame];
        
        CGFloat offsetX = MAX((self.bounds.size.width - self.contentSize.width) * 0.5, 0.0);
        CGFloat offsetY = MAX((self.bounds.size.height - self.contentSize.height) * 0.5, 0.0);
        
        self.contentImageView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX,
                                     self.contentSize.height * 0.5 + offsetY);
        if (self.selectView) {
            [self.selectView setFrame:frm];
        }
    }
}

- (UIView*) viewForZoomingInScrollView:(UIScrollView*)scrollView
{
    return self.contentImageView;
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
    _tileFrame = CGRectZero;
    _tileScale = 1;
    if (_tileView) {
        [_tileView removeFromSuperview];
        _tileView = nil;
    }
}

- (void) scrollViewDidEndZooming: (UIScrollView*)scrollView withView: (UIView*)view atScale: (CGFloat)scale
{
    [self loadTile];
}

- (void) resetZoomAnimated: (BOOL)animated
{
    // discard tile and any pending tile jobs
    _tileFrame = CGRectZero;
    _tileScale = 1;
    if (_tileView) {
        [_tileView removeFromSuperview];
    }
    
    [self setMinimumZoomScale: 1];
    [self setMaximumZoomScale: 5];
    [self setZoomScale: 1 animated: animated];
}

- (void)removeFromSuperview
{
    _cancel = YES;
    [super removeFromSuperview];
}

- (int)number
{
    return _number;
}

- (UIImageView*)contentImageView
{
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_contentImageView setUserInteractionEnabled:YES];
        [_contentImageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    return _contentImageView;
}

- (UIView *)tapView
{
    if (!_tapView) {
        _tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [_tapView setBackgroundColor:[UIColor redColor]];
    }
    
    return _tapView;
}



//- (void)updateConstraints
//{
//    if (self.autoSubViewConstraint) {
//        [self.autoSubViewConstraint autoRemoveConstraints];
//    }
//    
//    self.autoSubViewConstraint = [NSLayoutConstraint autoCreateConstraintsWithoutInstalling:^{
//        if (self.contentImageView.image) {
//            [self.contentImageView autoSetDimensionsToSize:self.contentImageView.image.size];
//            
////            [self.contentImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
////            [self.contentImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
//        }
//    }];
//    
//    [self.autoSubViewConstraint autoInstallConstraints];
//    
//    [super updateConstraints];
//}

@end
