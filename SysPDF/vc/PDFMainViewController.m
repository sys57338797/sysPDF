//
//  CMainViewController.m
//  SysPDF
//
//  Created by suyushen on 15/2/25.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//

#import "PDFMainViewController.h"
#import "UIViewController+Factory.h"
#import "UIViewController+NavBar.h"
#import "PureLayout.h"

#import "PDFFilesViewController.h"
#import "PDFWordTableViewController.h"
#import "NavManager.h"


@interface PDFMainViewController () <UITabBarControllerDelegate>

@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) PDFFilesViewController *fileController;
@property (nonatomic, strong) PDFWordTableViewController *wordController;
@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation PDFMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.tabBarController.view];
    
    self.barView = [self rightBtnNavBarWithTitle:@"单词列表" rightBtnTitle:nil rightBtnImage:[UIImage imageNamed:@"search.png"] rightBtnSEL:@selector(searchClick)];
    
    [self.view addSubview:self.barView];
    
    [self.view setNeedsUpdateConstraints];
    
}

- (void)searchClick
{
    [[NavManager shareInstance] showViewController:[UIViewController CreateControllerWithTag:CtrlTag_Translation] isAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[PDFFilesViewController class]]) {
        [self setNavBarTitle:@"PDF目录"];
    }
    else if ([viewController isKindOfClass:[PDFWordTableViewController class]]) {
        [self setNavBarTitle:@"单词列表"];
    }
    return YES;
}

- (void)updateViewConstraints
{
    if (!self.didSetupConstraints) {
        [self navBarUpdateViewConstraints];
        [self rightBtnNavBarUpdateViewConstraints];
        
        [self.tabBarController.view autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:[self navBarHeight]];
        [self.tabBarController.view autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.tabBarController.view autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.tabBarController.view autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        //        [self.protocolView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        
        self.didSetupConstraints = TRUE;
    }
    
    [super updateViewConstraints];
}

- (UITabBarController*)tabBarController
{
    if (!_tabBarController) {
        _tabBarController = [[UITabBarController alloc] init];
        _tabBarController.viewControllers = @[self.wordController,self.fileController];
        _tabBarController.delegate = self;
    }
    
    return _tabBarController;
}

- (PDFFilesViewController*)fileController
{
    if (!_fileController) {
        _fileController = (PDFFilesViewController*)[UIViewController CreateControllerWithTag:CtrlTag_FileList];
        _fileController.tabBarItem.title = @"PDF";
//        _fileController.tabBarItem.image = [UIImage imageNamed:@"main_bar_pdf.png"];
    }
    
    return _fileController;
}

- (PDFWordTableViewController*)wordController
{
    if (!_wordController) {
        _wordController = (PDFWordTableViewController*)[UIViewController CreateControllerWithTag:CtrlTag_Word];
        _wordController.tabBarItem.title = @"WORD";
//        _wordController.tabBarItem.image = [UIImage imageNamed:@"main_bar_word.png"];
    }
    
    return _wordController;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
