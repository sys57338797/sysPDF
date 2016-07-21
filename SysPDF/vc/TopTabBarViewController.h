//
//  TopTabBarViewController.h
//  test
//
//  Created by mutouren on 11/4/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopTabBarViewControllerDelegate <NSObject>

-(void) viewScrollToIndex:(NSInteger)index;

@end


@interface TopTabBarViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UIColor *selectedBtnTitleColor;
@property (nonatomic, strong) UIColor *unselectedBtnTitleColor;
@property (nonatomic, strong) UIColor *selectedLineColor;
@property (nonatomic, strong) UIColor *tabBarBottomLineColor;
@property (nonatomic, assign) CGFloat lineHeight;

@property (nonatomic, assign) id<TopTabBarViewControllerDelegate> delegate;

@property (nonatomic, strong,readonly) NSMutableArray *titles;//array of NSString
@property (nonatomic, strong,readonly) NSMutableArray *topChildControllers;//array of UIViewControllers
@property (nonatomic, strong,readonly) NSMutableArray *childViews;


- (instancetype)initTopTabBarViewControllerWithTitlesAndControllers:(NSDictionary *)titlesAndControllers;
+ (instancetype)topTabBarViewControllerWithTitlesAndControllers:(NSDictionary *)titlesAndControllers;
- (instancetype)initTopTabBarViewControllerWithTitles:(NSArray*) titles AndControllers:(NSArray *)controllers;

- (void)setDataWithTitleArray:(NSArray*)titleArray views:(NSArray*)viewArray;

@end
