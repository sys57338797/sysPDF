//
//  TopTabBarViewController.m
//  test
//
//  Created by mutouren on 11/4/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "TopTabBarViewController.h"
#import "PureLayout.h"


//static const CGFloat kNavbarButtonScaleFactor = 1.4f;


#define tabBarH 44.0f


@interface TopTabBarViewController ()

@property (nonatomic, strong) UIView *tabBar;                   //顶部tabBar
@property (nonatomic, strong) UIView *tabBarBottomLineView;     //tabbar底部的阴影线
@property (nonatomic, strong) UIView *tabBarBottomSelectView;   //tabbar底部左右滚动的的线
@property (nonatomic, strong) UIScrollView *contentScrollView;  //内容scrollView
@property (nonatomic, strong) NSArray *autoSubViewConstraint;

@end

@implementation TopTabBarViewController



- (instancetype)initTopTabBarViewControllerWithTitles:(NSArray*) titles AndControllers:(NSArray *)controllers
{
    
    if (titles.count != controllers.count) {
        return nil;
    }
    
    if (self = [self init]) {
        
        _titles = [NSMutableArray arrayWithArray:titles];
        _topChildControllers = [NSMutableArray arrayWithArray:controllers];
    }
    
    return self;
}

+ (instancetype)topTabBarViewControllerWithTitlesAndControllers:(NSDictionary *)titlesAndControllers
{
    return [[self alloc] initTopTabBarViewControllerWithTitlesAndControllers:titlesAndControllers];
}

- (instancetype)initTopTabBarViewControllerWithTitlesAndControllers:(NSDictionary *)titlesAndControllers
{
    if (self = [self init]) {
        
        [titlesAndControllers enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
            if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[UIViewController class]]) {
                
                [self.titles addObject:key];
                [self.topChildControllers addObject:obj];
            }
        }];
        
    }
    return self;
}



- (id)init
{
    self = [super init];
    if (self) {
        _titles = [NSMutableArray array];
        _topChildControllers = [NSMutableArray array];
        _childViews = [NSMutableArray array];
        self.selectedBtnTitleColor = [UIColor blueColor];
        self.unselectedBtnTitleColor = [UIColor blackColor];
        self.selectedLineColor = [UIColor blueColor];
        self.tabBarBottomLineColor = [UIColor grayColor];
        self.lineHeight = 1.0f;
    }
    
    return self;
}

- (void)setTopChildControllers:(NSMutableArray *)topChildControllers
{
    _topChildControllers = topChildControllers;
    
    NSMutableArray *views = [NSMutableArray array];
    for (UIViewController *vc in _topChildControllers) {
        [views addObject:vc.view];
    }
    _childViews = views;
}

- (void)setDataWithTitleArray:(NSArray*)titleArray views:(NSArray*)viewArray
{
    if (titleArray.count != viewArray.count) {
        return;
    }
    
    [self.titles addObjectsFromArray:titleArray];
    [self.childViews addObjectsFromArray:viewArray];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateViewConstraints];
}

- (void)viewDidLoad
{
    int tag = 1;
    for (NSString *title in self.titles) {
        UIButton *btn = [self createBtnWithTitle:title];
        btn.tag = tag;
        [self.tabBar addSubview:btn];
        
        tag++;
    }
    
    [self.view addSubview:self.tabBar];
    [self.view addSubview:self.tabBarBottomSelectView];
    [self.view addSubview:self.tabBarBottomLineView];
    
    for (UIView *v in self.childViews) {
        [self.contentScrollView addSubview:v];
    }
    
    [self.view addSubview:self.contentScrollView];
    
    //默认选择第一个按钮
    [self btnClick:(UIButton*)[self.tabBar viewWithTag:1]];
}

#pragma mark - Private Func

- (void)btnClick:(UIButton*)sender
{
    for (UIButton *btn in self.tabBar.subviews) {
        [btn setSelected:NO];
    }
    
    [sender setSelected:YES];
    
    _selectedIndex = sender.tag;
    
//    [self transitionToViewControllerAtIndex:(self.selectedIndex-1)];
    [self transitionForClickingAtIndex:(self.selectedIndex-1)];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewScrollToIndex:)]) {
        [self.delegate viewScrollToIndex:_selectedIndex];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    UIButton *btn = (UIButton*)[self.tabBar viewWithTag:_selectedIndex];
    
    [self btnClick:btn];
}


- (void)transitionToViewControllerAtIndex:(NSUInteger)index{
    [_contentScrollView setContentOffset:CGPointMake(index*_contentScrollView.frame.size.width, 0)];
    
}

- (void)transitionToViewController:(UIViewController *)controller{
    
    [self transitionToViewControllerAtIndex:[self.topChildControllers indexOfObject:controller]];
}

-(void)transitionForClickingAtIndex:(NSUInteger)index {
    CGFloat unitW = self.contentScrollView.bounds.size.width;
    CGFloat unitH = self.contentScrollView.bounds.size.height;
    
    CGRect dsRect = CGRectMake(index*unitW, self.contentScrollView.frame.origin.y, unitW, unitH);
    
    self.contentScrollView.contentSize = CGSizeMake(([self.titles count])*unitW, unitH);
    [self.contentScrollView scrollRectToVisible:dsRect animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (0==fmod(scrollView.contentOffset.x,scrollView.frame.size.width)){
        self.selectedIndex =  scrollView.contentOffset.x/scrollView.frame.size.width+1;
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    _selectedIndex =  scrollView.contentOffset.x/scrollView.frame.size.width+1
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    // 左 or 右
    UIButton *relativeButton = nil;
//    UIButton *currentBtn = [self currentSelectBtn];
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    
    CGFloat offset = scrollView.contentOffset.x-(_selectedIndex-1)*scrollViewWidth;
    
    if(offset>0 && _selectedIndex<[self.titles count]){//右
        relativeButton = (UIButton *)[self.tabBar viewWithTag:_selectedIndex+1];
    }else if(offset<0 && _selectedIndex>1){
        relativeButton = (UIButton *)[self.tabBar viewWithTag:_selectedIndex-1];
    }
    float pValues = offset/scrollView.frame.size.width;

//    float colorValues = fabs(pValues);
    CGRect tabBarSelectRect = self.tabBarBottomSelectView.frame;
    tabBarSelectRect.origin.x = tabBarSelectRect.size.width*(pValues+self.selectedIndex-1);
    self.tabBarBottomSelectView.frame = tabBarSelectRect;
    
    
//    UIColor *currentColor = [UIColor colorWithRed:((self.selectedBtnColor.red-self.unselectedBtnColor.red)*colorValues+self.unselectedBtnColor.red)
//                                            green:((self.selectedBtnColor.green-self.unselectedBtnColor.green)*colorValues+self.unselectedBtnColor.green)
//                                             blue:((self.selectedBtnColor.blue-self.unselectedBtnColor.blue)*colorValues+self.unselectedBtnColor.blue)
//                                            alpha:1];
//    
//    UIColor *relativeColor = [UIColor colorWithRed:((self.selectedBtnColor.red-self.unselectedBtnColor.red)*colorValues+[relativeButton titleColorForState:UIControlStateNormal].red)
//                                             green:((self.selectedBtnColor.green-self.unselectedBtnColor.green)*colorValues+[relativeButton titleColorForState:UIControlStateNormal].green)
//                                              blue:((self.selectedBtnColor.blue-self.unselectedBtnColor.blue)*colorValues+[relativeButton titleColorForState:UIControlStateNormal].blue)
//                                             alpha:1];
//
//    
//    [currentBtn setTitleColor:currentColor forState:UIControlStateNormal];
//    [relativeButton setTitleColor:relativeColor forState:UIControlStateNormal];
}

#pragma mark - Lazy Init

- (UIButton*)createBtnWithTitle:(NSString*)title
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:self.unselectedBtnTitleColor forState:UIControlStateNormal];
    [btn setTitleColor:self.selectedBtnTitleColor forState:UIControlStateSelected];
    
    return btn;
}

- (UIButton*)currentSelectBtn
{
    for (UIButton *btn in self.tabBar.subviews) {
        if (btn.isSelected) {
            return btn;
        }
    }
    
    return nil;
}

- (UIViewController*)currentSelectViewController
{
    for (UIButton *btn in self.tabBar.subviews) {
        if (btn.isSelected) {
            return [self.topChildControllers objectAtIndex:btn.tag-1];
        }
    }
    
    return nil;
}

- (UIView*)tabBar
{
    if (!_tabBar) {
        _tabBar = [[UIView alloc] initWithFrame:CGRectZero];
        [_tabBar setBackgroundColor:[UIColor whiteColor]];
    }
    
    return _tabBar;
}

- (UIView*)tabBarBottomLineView
{
    if (!_tabBarBottomLineView) {
        _tabBarBottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tabBarBottomLineView setBackgroundColor:self.tabBarBottomLineColor];
    }
    
    return _tabBarBottomLineView;
}

- (UIView*)tabBarBottomSelectView
{
    if (!_tabBarBottomSelectView) {
        _tabBarBottomSelectView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tabBarBottomSelectView setBackgroundColor:self.selectedLineColor];
    }
    
    return _tabBarBottomSelectView;
}

- (UIScrollView*)contentScrollView
{
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        //        _contentScrollView.contentOffset = CGPointMake(0, 0);
        //        _contentScrollView.contentSize =
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.bounces = NO;
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.delegate = self;
    }
    
    return _contentScrollView;
}

#pragma mark - AutoLayout

- (void)updateViewConstraints
{
    [self.tabBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tabBarBottomLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tabBarBottomSelectView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if (self.autoSubViewConstraint) {
        [self.autoSubViewConstraint autoRemoveConstraints];
    }
    
    for (UIView *view in self.tabBar.subviews) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    for (UIView *view in self.contentScrollView.subviews) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    self.autoSubViewConstraint = [NSLayoutConstraint autoCreateConstraintsWithoutInstalling:^{
        [self.tabBar autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.tabBar autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.tabBar autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
        [self.tabBar autoSetDimension:ALDimensionHeight toSize:tabBarH];
        
        [NSLayoutConstraint autoSetIdentifier:@"tab bar sub view edges" forConstraints:^{
            [self.tabBar.subviews autoMatchViewsDimension:ALDimensionWidth];
            [[self.tabBar.subviews firstObject] autoPinEdgeToSuperviewEdge:ALEdgeLeft];
            UIView *previousView = nil;
            for (UIView *view in self.tabBar.subviews) {
                if (previousView) {
                    [view autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:previousView];
                }
                [view autoPinEdgeToSuperviewEdge:ALEdgeTop];
                [view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.tabBar];
                previousView = view;
            }
            [[self.tabBar.subviews lastObject] autoPinEdgeToSuperviewEdge:ALEdgeRight];
        }];
        
        [self.tabBarBottomLineView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.tabBar];
        [self.tabBarBottomLineView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.tabBarBottomLineView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
        [self.tabBarBottomLineView autoSetDimension:ALDimensionHeight toSize:0.5f];
        
        [self.tabBarBottomSelectView autoSetDimension:ALDimensionHeight toSize:self.lineHeight];
        if (self.tabBar.subviews.count) {
            [self.tabBarBottomSelectView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:[self.tabBar.subviews objectAtIndex:0]];
        }
        [self.tabBarBottomSelectView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.tabBarBottomLineView];
        if ([self currentSelectBtn]) {
            [self.tabBarBottomSelectView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:[self currentSelectBtn]];
        }
        
        [self.contentScrollView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.tabBarBottomLineView];
        [self.contentScrollView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.contentScrollView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [self.contentScrollView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
        
        [NSLayoutConstraint autoSetIdentifier:@"contentScrollView sub view edges" forConstraints:^{
            [self.contentScrollView.subviews autoMatchViewsDimension:ALDimensionWidth];
            [[self.contentScrollView.subviews firstObject] autoPinEdgeToSuperviewEdge:ALEdgeLeft];
            UIView *previousView = nil;
            for (UIView *view in self.contentScrollView.subviews) {
                if (previousView) {
                    [view autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:previousView];
                }
                [view autoPinEdgeToSuperviewEdge:ALEdgeTop];
                [view autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentScrollView];
                [view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentScrollView];
                
                previousView = view;
            }
            [[self.contentScrollView.subviews lastObject] autoPinEdgeToSuperviewEdge:ALEdgeRight];
        }];
    }];
    
    [self.autoSubViewConstraint autoInstallConstraints];
    
    
    [super updateViewConstraints];
}

@end
