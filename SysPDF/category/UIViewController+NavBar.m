//
//  UIViewController+NavBar.m
//  CWGJCarPark
//
//  Created by mutouren on 9/7/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//

#import "UIViewController+NavBar.h"
#import "NavManager.h"
#import "UIView+Size.h"
#import "PureLayout.h"
#import <objc/runtime.h>
#import "UIView+Size.h"


void *BarViewKey = nil;
void *LayoutSubViewKey = nil;
void *RightBtnKey = nil;
void *LeftBtnKey = nil;
void *TitleLabelKey = nil;
void *SearchTextFieldKey = nil;
void *CancelBtnKey = nil;



@interface UIViewController ()

@property (nonatomic, strong) UIView *barLayoutSubView;
@property (nonatomic, strong) UIButton *barRightBtn;
@property (nonatomic, strong) UIButton *barLeftBtn;
@property (nonatomic, strong) UILabel *barTitleLabel;
@property (nonatomic, strong) UITextField *barSearchTextField;
@property (nonatomic, strong) UIButton *barCancelBtn;
@end

@implementation UIViewController (NavBar)


- (void)setBarView:(UIView *)barView
{
    objc_setAssociatedObject(self, &BarViewKey, barView, OBJC_ASSOCIATION_RETAIN);
}

- (UIView*)barView
{
    return objc_getAssociatedObject(self, &BarViewKey);
}

- (void)setBarLayoutSubView:(UIView *)layoutSubView
{
    objc_setAssociatedObject(self, &LayoutSubViewKey, layoutSubView, OBJC_ASSOCIATION_RETAIN);
}

- (UIView*)barLayoutSubView
{
    return objc_getAssociatedObject(self, &LayoutSubViewKey);
}

- (void)setBarRightBtn:(UIButton *)rightBtn
{
    objc_setAssociatedObject(self, &RightBtnKey, rightBtn, OBJC_ASSOCIATION_RETAIN);
}

- (UIButton*)barRightBtn
{
    return objc_getAssociatedObject(self, &RightBtnKey);
}

- (void)setBarLeftBtn:(UIButton *)leftBtn
{
    objc_setAssociatedObject(self, &LeftBtnKey, leftBtn, OBJC_ASSOCIATION_RETAIN);
}

- (UIButton*)barLeftBtn
{
    return objc_getAssociatedObject(self, &LeftBtnKey);
}

- (void)setBarTitleLabel:(UILabel *)titleLabel
{
    objc_setAssociatedObject(self, &TitleLabelKey, titleLabel, OBJC_ASSOCIATION_RETAIN);
}

- (UILabel*)barTitleLabel
{
    return objc_getAssociatedObject(self, &TitleLabelKey);
}

 -(UITextField*)barSearchTextField
{
    return objc_getAssociatedObject(self, &SearchTextFieldKey);
}

- (void)setBarSearchTextField:(UITextField *)searchTextField
{
    objc_setAssociatedObject(self, &SearchTextFieldKey, searchTextField, OBJC_ASSOCIATION_RETAIN);
}

- (UIButton*)barCancelBtn
{
    return objc_getAssociatedObject(self, &CancelBtnKey);
}

- (void)setBarCancelBtn:(UIButton *)cancelBtn
{
    objc_setAssociatedObject(self, &CancelBtnKey, cancelBtn, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark 主页面导航栏
- (UIView*)mainNavBarWithRightImage:(UIImage*)rightImage leftImage:(UIImage*)leftImage  rightBtnSEL:(SEL)rightBtnSel leftBtnSEL:(SEL)leftBtnSel
{
    UIView *barView = [[UIView alloc] initWithFrame:CGRectZero];//CGRectMake(0, 0, Screen_SIZE.width, BARHEIGHT)
    [barView setBackgroundColor:[UIColor clearColor]];
    
    UIView *layoutView = [[UIView alloc] initWithFrame:CGRectZero];
    [barView addSubview:layoutView];
    self.barLayoutSubView = layoutView;
    [self.barLayoutSubView setBackgroundColor:[UIColor clearColor]];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectZero;
//    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    [leftBtn setBackgroundColor:[UIColor clearColor]];
    //    [rightBtn setCenter:CGPointMake(0, 20+(barView.height-20)/2)];
    //    rightBtn.frame = CGRectMake(barView.width-rightBtn.width-10.0f, rightBtn.yOrigin, 80.0f, 36.0f);
//    leftBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    if (leftImage) {
//        [leftBtn setBackgroundImage:leftImage forState:UIControlStateNormal];
        [leftBtn setImage:leftImage forState:UIControlStateNormal];
    }
//    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (leftBtnSel) {
        [leftBtn addTarget:self action:leftBtnSel forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.barLayoutSubView addSubview:leftBtn];
    self.barLeftBtn = leftBtn;
    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];//CGRectMake(0, 0, 200, BARHEIGHT)
//    [titleLabel setCenter:CGPointMake(barView.width/2, 20+(barView.height-20)/2)];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.textColor = [UIColor whiteColor];
//    if (title) {
//        [titleLabel setText:title];
//    }
//    [self.layoutSubView addSubview:titleLabel];
//    self.titleLabel = titleLabel;
    
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectZero;
//    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -20.0f, 0, 0)];
    [rightBtn setBackgroundColor:[UIColor clearColor]];
//    [rightBtn setCenter:CGPointMake(0, 20+(barView.height-20)/2)];
//    rightBtn.frame = CGRectMake(barView.width-rightBtn.width-10.0f, rightBtn.yOrigin, 80.0f, 36.0f);
//    rightBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    if (rightImage) {
//        [rightBtn setBackgroundImage:rightImage forState:UIControlStateNormal];
        [rightBtn setImage:rightImage forState:UIControlStateNormal];
    }
//    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (rightBtnSel) {
        [rightBtn addTarget:self action:rightBtnSel forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.barLayoutSubView addSubview:rightBtn];
    self.barRightBtn = rightBtn;
    
    
    return barView;
}

#pragma mark 带一个标题的导航栏
- (UIView*)navBarWithTitle:(NSString*)title
{
    UIView *barView = [[UIView alloc] initWithFrame:CGRectZero];
    [barView setBackgroundColor:RGBA(250, 250, 250, 1.0f)];
    UIView *layoutView = [[UIView alloc] initWithFrame:CGRectZero];
    [barView addSubview:layoutView];
    self.barLayoutSubView = layoutView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [titleLabel setCenter:CGPointMake(barView.width/2, 20+(barView.height-20)/2)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    if (title) {
        [titleLabel setText:title];
    }
    [self.barLayoutSubView addSubview:titleLabel];
    
    self.barTitleLabel = titleLabel;
    
    return barView;
}


#pragma mark 带一个返回按钮的导航栏
- (UIView*)returnBtnNavBarWithTitle:(NSString*)title leftBtnSEL:(SEL)leftBtnSel
{
    UIView *barView = [[UIView alloc] initWithFrame:CGRectZero];//CGRectMake(0, 0, Screen_SIZE.width, BARHEIGHT)
    [barView setBackgroundColor:RGBA(250, 250, 250, 1.0f)];
    
    UIView *layoutView = [[UIView alloc] initWithFrame:CGRectZero];
    [layoutView setBackgroundColor:[UIColor clearColor]];
    [barView addSubview:layoutView];
    self.barLayoutSubView = layoutView;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectZero;
    //    [rightBtn setCenter:CGPointMake(0, 20+(barView.height-20)/2)];
    //    rightBtn.frame = CGRectMake(barView.width-rightBtn.width-10.0f, rightBtn.yOrigin, 80.0f, 36.0f);
    leftBtn.backgroundColor = [UIColor clearColor];
    leftBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [leftBtn setImage:[UIImage imageNamed:@"nav_back.png"] forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn setBackgroundColor:[UIColor clearColor]];
    
    if (leftBtnSel) {
        [leftBtn addTarget:self action:leftBtnSel forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [leftBtn addTarget:self action:@selector(leftBtnClickExt:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.barLayoutSubView addSubview:leftBtn];
    self.barLeftBtn = leftBtn;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];//CGRectMake(0, 0, 200, BARHEIGHT)
    [titleLabel setCenter:CGPointMake(barView.width/2, 20+(barView.height-20)/2)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    if (title) {
        [titleLabel setText:title];
    }
    [self.barLayoutSubView addSubview:titleLabel];
    self.barTitleLabel = titleLabel;
    
    return barView;
}

#pragma mark 带一个返回按钮和右边按钮的导航栏
- (UIView*)returnBtnAndRightBtnNavBarWithTitle:(NSString*)title rightBtnTitle:(NSString*)btnTitle rightBtnImage:(UIImage*)btnImage leftBtnSEL:(SEL)leftBtnSel rightBtnSEL:(SEL)rightBtnSel
{
    UIView *barView = [[UIView alloc] initWithFrame:CGRectZero];//CGRectMake(0, 0, Screen_SIZE.width, BARHEIGHT)
    [barView setBackgroundColor:RGBA(250, 250, 250, 1.0f)];
    
    UIView *layoutView = [[UIView alloc] initWithFrame:CGRectZero];
    [barView addSubview:layoutView];
    self.barLayoutSubView = layoutView;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectZero;
    //    [rightBtn setCenter:CGPointMake(0, 20+(barView.height-20)/2)];
    //    rightBtn.frame = CGRectMake(barView.width-rightBtn.width-10.0f, rightBtn.yOrigin, 80.0f, 36.0f);
    leftBtn.backgroundColor = [UIColor clearColor];
    leftBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [leftBtn setImage:[UIImage imageNamed:@"nav_back.png"] forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    if (leftBtnSel) {
        [leftBtn addTarget:self action:leftBtnSel forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [leftBtn addTarget:self action:@selector(leftBtnClickExt:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.barLayoutSubView addSubview:leftBtn];
    self.barLeftBtn = leftBtn;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];//CGRectMake(0, 0, 200, BARHEIGHT)
    [titleLabel setCenter:CGPointMake(barView.width/2, 20+(barView.height-20)/2)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    if (title) {
        [titleLabel setText:title];
    }
    [self.barLayoutSubView addSubview:titleLabel];
    self.barTitleLabel = titleLabel;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectZero;
    //    [rightBtn setCenter:CGPointMake(0, 20+(barView.height-20)/2)];
    //    rightBtn.frame = CGRectMake(barView.width-rightBtn.width-10.0f, rightBtn.yOrigin, 80.0f, 36.0f);
    rightBtn.backgroundColor = [UIColor clearColor];
    rightBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    if (btnImage) {
        [rightBtn setImage:btnImage forState:UIControlStateNormal];
    }
    else if (btnTitle) {
        [rightBtn setTitle:btnTitle forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    if (rightBtnSel) {
        [rightBtn addTarget:self action:rightBtnSel forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.barLayoutSubView addSubview:rightBtn];
    self.barRightBtn = rightBtn;
    
    return barView;
}

#pragma mark 带搜索栏的导航栏
- (UIView*)searchBarWithPlaceholder:(NSString*)placeholder textFiledLeftView:(UIView*)leftView cancelBtnTitle:(NSString*)btnTitle cancelBtnSEL:(SEL)cancelBtnSel
{
    UIView *barView = [[UIView alloc] initWithFrame:CGRectZero];
    [barView setBackgroundColor:RGBA(250, 250, 250, 1.0f)];
    
    UIView *layoutView = [[UIView alloc] initWithFrame:CGRectZero];
    [barView addSubview:layoutView];
    self.barLayoutSubView = layoutView;
    
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = placeholder;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [textField setTextColor:[UIColor blackColor]];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setCornerRadius:10.0f];
    [self.barLayoutSubView addSubview:textField];
    self.barSearchTextField = textField;
    
    if (leftView) {
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.leftView = leftView;
    }
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectZero;
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    if (btnTitle) {
        [cancelBtn setTitle:btnTitle forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if (cancelBtnSel) {
        [cancelBtn addTarget:self action:cancelBtnSel forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.barLayoutSubView addSubview:cancelBtn];
    self.barCancelBtn = cancelBtn;
    
    return barView;
}

#pragma mark 带一个右边按钮的导航栏
- (UIView*)rightBtnNavBarWithTitle:(NSString*)title rightBtnTitle:(NSString*)btnTitle rightBtnImage:(UIImage*)btnImage rightBtnSEL:(SEL)rightBtnSel
{
    UIView *barView = [[UIView alloc] initWithFrame:CGRectZero];
    [barView setBackgroundColor:RGBA(250, 250, 250, 1.0f)];
    
    UIView *layoutView = [[UIView alloc] initWithFrame:CGRectZero];
    [barView addSubview:layoutView];
    self.barLayoutSubView = layoutView;
    
//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    leftBtn.frame = CGRectZero;
//    //    [rightBtn setCenter:CGPointMake(0, 20+(barView.height-20)/2)];
//    //    rightBtn.frame = CGRectMake(barView.width-rightBtn.width-10.0f, rightBtn.yOrigin, 80.0f, 36.0f);
//    leftBtn.backgroundColor = [UIColor clearColor];
//    leftBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
//    [leftBtn setImage:kImage(@"nav_back.png") forState:UIControlStateNormal];
//    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    
//    if (leftBtnSel) {
//        [leftBtn addTarget:self action:leftBtnSel forControlEvents:UIControlEventTouchUpInside];
//    }
//    else {
//        [leftBtn addTarget:self action:@selector(leftBtnClickExt:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    [self.layoutSubView addSubview:leftBtn];
//    self.leftBtn = leftBtn;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];//CGRectMake(0, 0, 200, BARHEIGHT)
    [titleLabel setCenter:CGPointMake(barView.width/2, 20+(barView.height-20)/2)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    if (title) {
        [titleLabel setText:title];
    }
    [self.barLayoutSubView addSubview:titleLabel];
    self.barTitleLabel = titleLabel;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectZero;
    //    [rightBtn setCenter:CGPointMake(0, 20+(barView.height-20)/2)];
    //    rightBtn.frame = CGRectMake(barView.width-rightBtn.width-10.0f, rightBtn.yOrigin, 80.0f, 36.0f);
    rightBtn.backgroundColor = [UIColor clearColor];
    rightBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    if (btnImage) {
        [rightBtn setImage:btnImage forState:UIControlStateNormal];
    }
    else if (btnTitle) {
        [rightBtn setTitle:btnTitle forState:UIControlStateNormal];
        [rightBtn setTitleColor:RGBA(74, 144, 223, 1.0f) forState:UIControlStateNormal];
    }
    
    if (rightBtnSel) {
        [rightBtn addTarget:self action:rightBtnSel forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.barLayoutSubView addSubview:rightBtn];
    self.barRightBtn = rightBtn;
    
    return barView;
}

#pragma mark 设置 navBar title
- (void)setNavBarTitle:(NSString*)title
{
    [self.barTitleLabel setText:title];
}

#pragma mark 左边按钮默认点击事件
- (void)leftBtnClickExt:(id)sender
{
    [[NavManager shareInstance] returnToFrontView:YES];
}

#pragma mark 返回bar的高度
- (CGFloat)navBarHeight
{
    return BARHEIGHT;
}

#pragma mark navBar 布局
- (void)navBarUpdateViewConstraints
{
    
    [self.barView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.barView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.barView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
    [self.barView autoSetDimension:ALDimensionHeight toSize:BARHEIGHT];
}

#pragma mark 主页面布局
- (void)mainNavBarUpdateViewConstraints
{
    
    [NSLayoutConstraint autoSetIdentifier:@"layout view edges" forConstraints:^{
        [self.barLayoutSubView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0f];
        [self.barLayoutSubView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.barLayoutSubView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) excludingEdge:ALEdgeTop];
    }];
    
    
    [NSLayoutConstraint autoSetIdentifier:@"layout sub view edges" forConstraints:^{
        [self.barLeftBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:MAIN_PAG_Y];
        [self.barLeftBtn autoSetDimensionsToSize:CGSizeMake(65, 35)];
        [self.barLeftBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        [self.barRightBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:MAIN_PAG_Y];
        [self.barRightBtn autoSetDimensionsToSize:CGSizeMake(65, 35)];
        [@[self.barRightBtn,self.barRightBtn] autoAlignViewsToAxis:ALAxisHorizontal];
    }];
}

#pragma mark 带一个返回按钮导航栏布局
- (void)returnBtnNavBarUpdateViewConstraints
{
    
    [NSLayoutConstraint autoSetIdentifier:@"layout view edges" forConstraints:^{
        [self.barLayoutSubView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0f];
        [self.barLayoutSubView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.barLayoutSubView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) excludingEdge:ALEdgeTop];
    }];
    
    
    [NSLayoutConstraint autoSetIdentifier:@"layout sub view edges" forConstraints:^{
        [self.barTitleLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.barLayoutSubView];
        [self.barTitleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.barTitleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        [self.barLeftBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:PAG_Y];
        [self.barLeftBtn autoSetDimensionsToSize:CGSizeMake(50.0f, 30.0f)];
        
        
        [@[self.barTitleLabel,self.barLeftBtn] autoAlignViewsToAxis:ALAxisHorizontal];
    }];
}

#pragma mark 带一个返回按钮和右边按钮的导航栏布局
- (void)returnBtnAndRightBtnNavBarUpdateViewConstraints
{
    
    [NSLayoutConstraint autoSetIdentifier:@"layout view edges" forConstraints:^{
        [self.barLayoutSubView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0f];
        [self.barLayoutSubView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.barLayoutSubView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) excludingEdge:ALEdgeTop];
    }];
    
    
    [NSLayoutConstraint autoSetIdentifier:@"layout sub view edges" forConstraints:^{
        [self.barTitleLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.barLayoutSubView];
        [self.barTitleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.barTitleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        [self.barLeftBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:PAG_Y];
        [self.barLeftBtn autoSetDimensionsToSize:CGSizeMake(self.barLeftBtn.currentImage.size.width+10.0f, self.barLeftBtn.currentImage.size.height)];
        
        [self.barRightBtn autoSetDimensionsToSize:CGSizeMake(65, 35)];
        [self.barRightBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:PAG_Y];
        
        [@[self.barTitleLabel,self.barLeftBtn,self.barRightBtn] autoAlignViewsToAxis:ALAxisHorizontal];
    }];
}

#pragma mark 带一个右边按钮的导航栏布局
- (void)rightBtnNavBarUpdateViewConstraints
{
    
    [NSLayoutConstraint autoSetIdentifier:@"layout view edges" forConstraints:^{
        [self.barLayoutSubView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0f];
        [self.barLayoutSubView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.barLayoutSubView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) excludingEdge:ALEdgeTop];
    }];
    
    
    [NSLayoutConstraint autoSetIdentifier:@"layout sub view edges" forConstraints:^{
        [self.barTitleLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.barLayoutSubView];
        [self.barTitleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.barTitleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];

        [self.barRightBtn autoSetDimensionsToSize:CGSizeMake(65.0f, 35.0f)];
         
        [self.barRightBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:PAG_Y];
        
        [@[self.barTitleLabel,self.barRightBtn] autoAlignViewsToAxis:ALAxisHorizontal];
    }];
}

#pragma mark 带一个搜索栏和取消按钮的导航栏布局
- (void)searchBarAndCancelBtnNavBarUpdateViewConstraints
{
    
    [NSLayoutConstraint autoSetIdentifier:@"layout view edges" forConstraints:^{
        [self.barLayoutSubView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0f];
        [self.barLayoutSubView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.barLayoutSubView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) excludingEdge:ALEdgeTop];
    }];
    
    
    [NSLayoutConstraint autoSetIdentifier:@"layout sub view edges" forConstraints:^{
        [self.barSearchTextField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:PAG_Y];
        [self.barSearchTextField autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:PAG_Y];
        [self.barSearchTextField autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:PAG_Y];
        [self.barSearchTextField autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.barCancelBtn withOffset:PAG_Y];
        
        [self.barCancelBtn autoSetDimensionsToSize:CGSizeMake(65.0f, 35.0f)];
        [self.barCancelBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:PAG_Y];
        
        [@[self.barSearchTextField,self.barCancelBtn] autoAlignViewsToAxis:ALAxisHorizontal];
    }];
}

- (void)titleNavBarUpdateViewConstraints
{
    
    [NSLayoutConstraint autoSetIdentifier:@"layout view edges" forConstraints:^{
        [self.barLayoutSubView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0f];
        [self.barLayoutSubView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.barLayoutSubView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) excludingEdge:ALEdgeTop];
    }];
    
    
    [NSLayoutConstraint autoSetIdentifier:@"layout sub view edges" forConstraints:^{
        [self.barTitleLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.barLayoutSubView];
        [self.barTitleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.barTitleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    }];
}


@end
