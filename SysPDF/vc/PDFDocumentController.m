//
//  PDFDocumentController.m
//  MuPDF
//
//  Created by mutouren on 8/20/13.
//
//

#import "PDFDocumentController.h"
#import "PDFWordObj.h"
#import "PDFDocumentWordView.h"
#import "PDFWordTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NavManager.h"
#import "PureLayout.h"
#import "AppDelegate+InterfaceOrientation.h"
#import "UIViewController+NavBar.h"
#import "PDFHttpServer.h"
#import "UIView+Size.h"
#import "PDFMuPageViewDelegate.h"
#import "PDFMuPageView.h"

#define HideSec 2.0f

@interface PDFScrollView : UIScrollView

@end

@implementation PDFScrollView

- (void)setContentSize:(CGSize)contentSize
{
    if (!CGSizeEqualToSize(contentSize, CGSizeZero)) {
        [super setContentSize:contentSize];
    }
}

@end


@interface PDFDocumentController () <BaseHttpServerCallBackDelegate>

@property (nonatomic, strong) PDFScrollView *scrollView;

@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, assign) BOOL allViewIsHidden;
@property (nonatomic, assign) CGRect leftBtnLastRect;
@property (nonatomic, assign) CGRect rightBtnLastRect;
@property (nonatomic, assign) CGRect bottomViewLastRect;
@property (nonatomic, assign) CGRect barViewLastRect;
@property (nonatomic, assign) BOOL isAllowHideAllView;
@property (nonatomic, assign) BOOL scrollAnimating;

@property (nonatomic, assign) BOOL isInitFirstPage;

@property (nonatomic, strong) PDFHttpServer *pdfHttpServer;

@property (nonatomic, assign) CGPoint singleTapPoint;

@end

@implementation PDFDocumentController


- (id)init
{
    self = [super init];
    if (self) {
        self.allViewIsHidden = NO;
        self.isInitFirstPage = NO;
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"PDFDocumentController dealloc !!!");
}

- (void)barLeftBtnClick
{
    [[NavManager shareInstance] returnToFrontView:YES];
    [[PDFManager shareInstance] closeDocument];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.scrollView setContentInset:UIEdgeInsetsZero];
    CGSize s = CGSizeMake([[PDFManager shareInstance] maxPage] * self.scrollView.width, self.scrollView.height);
    [self.scrollView setContentSize:s];
    
    if (!self.isInitFirstPage) {
        if (self.scrollView.frame.size.width > self.scrollView.frame.size.height) {
            [self initFirstPage];
            self.isInitFirstPage = YES;
        }
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.scrollView];
    
    self.barView = [self returnBtnNavBarWithTitle:[PDFManager shareInstance].openObj.bookName leftBtnSEL:@selector(barLeftBtnClick)];
    [self.barTitleLabel setTextColor:[UIColor whiteColor]];
    [self.barView setBackgroundColor:RGBA(0, 0, 0, 0.6f)];
    [self.view addSubview:self.barView];
    [self.view addSubview:self.leftBtn];
    [self.view addSubview:self.rightBtn];
    [self.view addSubview:self.bottomView];
    
    [self.bottomView addSubview:self.slider];
    [self.bottomView addSubview:self.pageLabel];
    
    [self.slider setMinimumValue:0];
    [self.slider setMaximumValue:[[PDFManager shareInstance] maxPage]];
    
    [self setPageLabelTextWithMinPage:0 maxPage:9999];
    
    
    self.scrollAnimating = NO;
    
    self.allViewIsHidden = NO;
    [self timeAfterHideAllSubViewForSec:3.0f];
    
    [self.view setNeedsUpdateConstraints];
//    [self.view updateConstraintsIfNeeded];
//    [self.view setNeedsLayout];
//    [self.view layoutIfNeeded];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NavManager shareInstance] setShouldAutorotate:NO];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    [[NavManager shareInstance] setShouldAutorotate:YES];
}

- (void)initFirstPage
{
    long page = 0;
    if ([PDFManager shareInstance].currentPage > 0 && [PDFManager shareInstance].currentPage < [PDFManager shareInstance].maxPage) {
        page = [PDFManager shareInstance].currentPage-1;
    }
    
    [self gotoPage:page animated:YES];
}

- (void)leftBtnClick
{
    self.isAllowHideAllView = NO;
    long current = [PDFManager shareInstance].currentPage - 1;
    [self gotoPage:current animated:NO];
}

- (void)rightBtnClick
{
    self.isAllowHideAllView = NO;
    long current = [PDFManager shareInstance].currentPage + 1;
    [self gotoPage:current animated:NO];
}

- (void)sliderValueChanged
{
    self.isAllowHideAllView = NO;
    
    int number = [self.slider value];
    if ([self.slider isTracking])
        [self setPageLabelTextWithMinPage:number+1 maxPage:[[PDFManager shareInstance] maxPage]];
    else
        [self gotoPage: number animated:NO];
}

- (void)showAllSubView
{
    [self.barView setHidden:NO];
    [self.leftBtn setHidden:NO];
    [self.rightBtn setHidden:NO];
    [self.bottomView setHidden:NO];
    
    [UIView animateWithDuration:0.2 animations:^{
        if (!CGRectIsEmpty(self.barViewLastRect)) {
            self.barView.frame = self.barViewLastRect;
        }
        
        if (!CGRectIsEmpty(self.leftBtnLastRect)) {
            self.leftBtn.frame = self.leftBtnLastRect;
        }
        
        if (!CGRectIsEmpty(self.rightBtnLastRect)) {
            self.rightBtn.frame = self.rightBtnLastRect;
        }
        
        if (!CGRectIsEmpty(self.bottomViewLastRect)) {
            self.bottomView.frame = self.bottomViewLastRect;
        }
    } completion:^(BOOL finished) {
        self.allViewIsHidden = NO;
        self.barViewLastRect = CGRectZero;
        self.leftBtnLastRect = CGRectZero;
        self.rightBtnLastRect = CGRectZero;
        self.bottomViewLastRect = CGRectZero;
        
        [self timeAfterHideAllSubViewForSec:HideSec];
    }];
}

- (void)timeAfterHideAllSubViewForSec:(CGFloat)sec
{
    self.isAllowHideAllView = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isAllowHideAllView) {
            if (!self.allViewIsHidden) {
                [self hideAllSubView];
            }
        }
    });
}

- (void)hideAllSubView
{
    [UIView animateWithDuration:0.2 animations:^{
        
        self.barViewLastRect = self.barView.frame;
        self.barView.frame = CGRectMake(self.barView.left, self.barView.top-self.barView.height, self.barView.width, self.barView.height);
        
        self.leftBtnLastRect = self.leftBtn.frame;
        self.leftBtn.frame = CGRectMake(self.leftBtn.left-self.leftBtn.width, self.leftBtn.top, self.leftBtn.width, self.leftBtn.height);
        
        self.rightBtnLastRect = self.rightBtn.frame;
        self.rightBtn.frame = CGRectMake(self.rightBtn.left+self.rightBtn.width, self.rightBtn.top, self.rightBtn.width, self.rightBtn.height);
        
        self.bottomViewLastRect = self.bottomView.frame;
        self.bottomView.frame = CGRectMake(self.bottomView.left, self.bottomView.top+self.bottomView.height, self.bottomView.width, self.bottomView.height);
    } completion:^(BOOL finished) {
        self.allViewIsHidden = YES;
        [self.barView setHidden:YES];
        [self.leftBtn setHidden:YES];
        [self.rightBtn setHidden:YES];
        [self.bottomView setHidden:YES];
    }];
}

- (void)setPageLabelTextWithMinPage:(long)min maxPage:(long)max
{
    [self.pageLabel setText:[NSString stringWithFormat: @" %ld of %ld ",min,max]];
}

- (void)onTap:(UITapGestureRecognizer*)sender
{
    if (sender.numberOfTapsRequired == 2) {
        if (self.allViewIsHidden) {
            [self showAllSubView];
        }
        else {
            [self hideAllSubView];
        }
    }
    
}

- (UIView*)createPageView:(int)number
{
    UIView *v = nil;
    if (number < 0 || number >= [[PDFManager shareInstance] maxPage])
        return v;
    
    int found = 0;
    
    for (UIView<PDFMuPageViewDelegate> *view in [self.scrollView subviews])
        if ([view number] == number)
        {
            found = 1;
        }
    
    
    if (!found) {
        UIView<PDFMuPageViewDelegate> *view = [[PDFMuPageView alloc] initWithFrame:CGRectZero document:[PDFManager shareInstance].doc page:number];
        [self.scrollView addSubview:view];
        v = view;
    }
    
    return v;
}

- (void)removeNonUseView
{
    NSMutableSet *invisiblePages = [[NSMutableSet alloc] init];
    for (UIView<PDFMuPageViewDelegate> *view in [self.scrollView subviews]) {
        if ([view number] != [PDFManager shareInstance].currentPage)
            [view resetZoomAnimated: YES];
        if ([view number] < [PDFManager shareInstance].currentPage - 2 || [view number] > [PDFManager shareInstance].currentPage + 2)
            [invisiblePages addObject: view];
    }
    [invisiblePages makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void) gotoPage: (long)number animated: (BOOL)animated
{
    if (number < 0)
        number = 0;
    if (number >= [[PDFManager shareInstance] maxPage])
        number = [[PDFManager shareInstance] maxPage]-1;
    if (animated) {
        // setContentOffset:animated: does not use the normal animation
        // framework. It also doesn't play nice with the tap gesture
        // recognizer. So we do our own page flipping animation here.
        // We must set the scroll_animating flag so that we don't create
        // or remove subviews until after the animation, or they'll
        // swoop in from origo during the animation.
        
        self.scrollAnimating = YES;
        [UIView beginAnimations: @"MuScroll" context: NULL];
        [UIView setAnimationDuration: 0.4];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(onGotoPageFinished)];
        
        for (UIView<PDFMuPageViewDelegate> *view in [self.scrollView subviews])
            [view resetZoomAnimated: NO];
        
        [self.scrollView setContentOffset:CGPointMake(number * self.scrollView.width, 0)];
        
        [UIView commitAnimations];
    } else {
        for (UIView<PDFMuPageViewDelegate> *view in [self.scrollView subviews])
            [view resetZoomAnimated: NO];

        [self.scrollView setContentOffset:CGPointMake(number * self.scrollView.width, 0)];
    }
}

- (void) onGotoPageFinished
{
    self.scrollAnimating = NO;
    [self scrollViewDidScroll:self.scrollView];
}

- (void) showSearchResults:(int)count forPage:(int)number
{
//    UIScrollView *canvas = (UIScrollView*)[self.view viewWithTag:PDFDocumentView_ScrollView_content];
//	searchPage = number;
//	[self gotoPage: number animated: NO];
//	for (MuPageView *view in [canvas subviews])
//		if ([view number] == number)
//            [view showSearchResultsWithRect:[CFZ_Administrator shareInstance].searchWordObj.rect];
////			[view showSearchResults: count];
//		else
//			[view clearSearchResults];
}


/*
- (void) resetSearch
{
	searchPage = -1;
	for (MuPageView *view in [canvas subviews])
		[view clearSearchResults];
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIScrollViewDelegate
- (void) scrollViewDidScroll: (UIScrollView*)scrollview
{
    if (self.scrollAnimating)
        return;
    
//    CGRect f = self.scrollView.frame;
//    CGSize s = self.scrollView.contentSize;
    CGFloat width = self.scrollView.width;
    float x = [self.scrollView contentOffset].x +  width * 0.5f;
    int current = x / width;
    
    NSLog(@"current page count ===>%d",current);
    
    if ([PDFManager shareInstance].currentPage != current) {
        [[PDFManager shareInstance] setCurrentPage:current];
        
        [self setPageLabelTextWithMinPage:[PDFManager shareInstance].currentPage+1 maxPage:[[PDFManager shareInstance] maxPage]];
        [self.slider setValue:current];
        
        // swap the distant page views out
        
        [self removeNonUseView];
        
        [self createPageView:current];
        [self createPageView:current - 1];
        [self createPageView:current + 1];
        
        [self.view setNeedsUpdateConstraints];
    }
}

#pragma mark BaseHttpServerCallBackDelegate
- (void)requestCallDidSuccess:(BaseHttpServer *)server
{

}

- (void)requestCallDidFailed:(BaseHttpServer *)server
{
    
}

- (PDFScrollView*)scrollView
{
    if (!_scrollView) {
        _scrollView = [[PDFScrollView alloc] initWithFrame:CGRectZero];
        [_scrollView setPagingEnabled: YES];
        [_scrollView setShowsHorizontalScrollIndicator: NO];
        [_scrollView setShowsVerticalScrollIndicator: NO];
        [_scrollView setDelegate:self];
        [_scrollView setBackgroundColor:[UIColor whiteColor]];
        
//        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
//        [singleTapGestureRecognizer setNumberOfTapsRequired:1];
//        [_scrollView addGestureRecognizer:singleTapGestureRecognizer];

        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [_scrollView addGestureRecognizer:doubleTapGestureRecognizer];
        
//        [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    }
    
    return _scrollView;
}

- (UIButton*)leftBtn
{
    if (!_leftBtn) {
        _leftBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_leftBtn setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _leftBtn;
}

- (UIButton*)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_rightBtn setImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _rightBtn;
}

- (UIView*)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        [_bottomView setBackgroundColor:RGBA(0, 0, 0, 0.6f)];
    }
    
    return _bottomView;
}

- (UISlider*)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectZero];
        [_slider addTarget:self action:@selector(sliderValueChanged) forControlEvents: UIControlEventValueChanged];
    }
    
    return _slider;
}

- (UILabel*)pageLabel
{
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_pageLabel setTextColor:[UIColor whiteColor]];
        [_pageLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [_pageLabel setTextAlignment:NSTextAlignmentCenter];
        [_pageLabel setBackgroundColor:[UIColor clearColor]];
    }
    
    return _pageLabel;
}

- (PDFHttpServer*)pdfHttpServer
{
    if (!_pdfHttpServer) {
        _pdfHttpServer = [[PDFHttpServer alloc] init];
        _pdfHttpServer.delegate = self;
    }
    
    return _pdfHttpServer;
}

- (void)controllerViewUpdateViewConstraints
{
    if (!self.barView.isHidden) {
        [self navBarUpdateViewConstraints];
        [self returnBtnNavBarUpdateViewConstraints];
    }
    
    [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    if (!self.leftBtn.isHidden && !self.rightBtn.isHidden) {
        [self.leftBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.leftBtn autoSetDimensionsToSize:CGSizeMake(self.leftBtn.currentImage.size.width+12.0f, self.leftBtn.currentImage.size.height+42.0f)];
        [self.rightBtn autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.rightBtn autoSetDimensionsToSize:CGSizeMake(self.rightBtn.currentImage.size.width+12.0f, self.rightBtn.currentImage.size.height+42.0f)];
        [self.leftBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [@[self.leftBtn,self.rightBtn] autoAlignViewsToAxis:ALAxisHorizontal];
    }
    
    if (!self.bottomView.isHidden) {
        [self.bottomView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.bottomView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.bottomView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [self.bottomView autoSetDimension:ALDimensionHeight toSize:50.0f];
        
        [self.pageLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:8.0f];
        [self.pageLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:8.0f];
        [self.pageLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.pageLabel autoSetDimension:ALDimensionHeight toSize:25.0f];
        
        [self.slider autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.pageLabel];
        [self.slider autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.pageLabel];
        [self.slider autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.pageLabel];
        [self.slider autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    }
    
}

- (void)scrollViewSubViewUpdateViewConstraints
{
    NSArray *subViews = [self.scrollView.subviews sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([(PDFMuPageView*)obj1 number] > [(PDFMuPageView*)obj2 number]) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedAscending;
        }
    }];
    
    for (UIView<PDFMuPageViewDelegate> *view in subViews) {
        NSLog(@"view.number===>%d",[view number]);
        if (view.translatesAutoresizingMaskIntoConstraints) {
            [view autoPinEdgeToSuperviewEdge:ALEdgeTop];
            [view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.scrollView];
            [view autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.scrollView];
            [view autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:[view number]*self.scrollView.width];
        }
    }
    
}

- (void)updateViewConstraints
{
    [self controllerViewUpdateViewConstraints];
    [self scrollViewSubViewUpdateViewConstraints];
    
    [super updateViewConstraints];
}

@end
