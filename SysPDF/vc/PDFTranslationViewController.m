//
//  PDFTranslationViewController.m
//  SysPDF
//
//  Created by mutouren on 3/24/16.
//  Copyright © 2016 suyushen. All rights reserved.
//

#import "PDFTranslationViewController.h"
#import "UIViewController+NavBar.h"
#import "NavManager.h"
#import "PureLayout.h"
#import "PDFHttpServer.h"
#import "MBProgressHUD+PDFMB.h"
#import "NSString+StringJudge.h"
#import "PDFWordTableViewCell.h"


@interface PDFTranslationViewController () <UITableViewDataSource,UITableViewDelegate, BaseHttpServerCallBackDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *closeKeyboardView;
@property (nonatomic, assign) BOOL didSetupConstraints;

@property (nonatomic, strong) PDFWordObj *searchObj;
@property (nonatomic, strong) PDFHttpServer *pdfHttpServer;

@end


@implementation PDFTranslationViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.dataArray = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.tabBarController.view];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search.png"]];
    
    self.barView = [self searchBarWithPlaceholder:@"输入单词。。。" textFiledLeftView:imageView cancelBtnTitle:@"取消" cancelBtnSEL:@selector(cancelBtnClick)];
    
    [self.barView setBackgroundColor:RGBA(107, 161, 99, 1.0f)];
    
    [self.view addSubview:self.barView];
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.closeKeyboardView];
    
    [self.view setNeedsUpdateConstraints];
    
    self.barSearchTextField.delegate = self;
    self.barSearchTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.barSearchTextField.returnKeyType = UIReturnKeySearch;
    [self.barSearchTextField becomeFirstResponder];
}

- (void)cancelBtnClick
{
    [[NavManager shareInstance] returnToFrontView:YES];
}

- (void)closeKeyboardViewClick:(id)sender
{
    [self.closeKeyboardView setHidden:YES];
    [self.barSearchTextField resignFirstResponder];
}

#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger rowCount = 0;
    if (self.searchObj) {
        if (self.searchObj.webCHContentArray.count > 1) {
            return self.searchObj.webCHContentArray.count;
        }
    }
    
    return rowCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger sectionCount = 1;
    if (self.searchObj) {
        if (self.searchObj.webCHContentArray&&self.searchObj.webCHContentArray.count) {
            sectionCount = 2;
        }
    }
    return sectionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MUPDFmutouren";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.barSearchTextField.text.length) {
        if ([self.barSearchTextField.text isEnglishString]) {
            NSString *word = [self.barSearchTextField.text lowercaseString];
            [self.pdfHttpServer requestPDFWordInfoWithWord:word];
        }
        else {
            [MBProgressHUD showHUDWithText:@"格式错误，只能是字母!!!" hideDelay:1.0f];
        }
    }
    else {
        [MBProgressHUD showHUDWithText:@"请输入单词!!!" hideDelay:1.0f];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.closeKeyboardView setHidden:NO];
    return YES;
}

#pragma mark BaseHttpServerCallBackDelegate
- (void)requestCallDidSuccess:(BaseHttpServer *)server
{
    if ([server isKindOfClass:[PDFHttpServer class]]) {
        PDFWordObj *obj = [(PDFHttpServer*)server wordObj];
        self.searchObj = obj;
        [self.tableView reloadData];
    }
}

- (void)requestCallDidFailed:(BaseHttpServer *)server
{
    if ([server isKindOfClass:[PDFHttpServer class]]) {
        [MBProgressHUD showHUDWithText:@"请输入单词!!!" hideDelay:1.0f];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViewConstraints
{
    if (!self.didSetupConstraints) {
        
        [self navBarUpdateViewConstraints];
        [self searchBarAndCancelBtnNavBarUpdateViewConstraints];
        
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:[self navBarHeight]];
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        [self.closeKeyboardView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:[self navBarHeight]];
        [self.closeKeyboardView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.closeKeyboardView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.closeKeyboardView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        //        [self.protocolView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        
        self.didSetupConstraints = TRUE;
    }
    
    [super updateViewConstraints];
}

- (UITableView*)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (UIView*)closeKeyboardView
{
    if (!_closeKeyboardView) {
        _closeKeyboardView = [[UIView alloc] initWithFrame:CGRectZero];
        [_closeKeyboardView setBackgroundColor:[UIColor clearColor]];
        [_closeKeyboardView setHidden:YES];
        
        UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboardViewClick:)];
        //点击的次数
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        
        [_closeKeyboardView addGestureRecognizer:singleRecognizer];
    }
    
    return _closeKeyboardView;
}

- (PDFHttpServer*)pdfHttpServer
{
    if (!_pdfHttpServer) {
        _pdfHttpServer = [[PDFHttpServer alloc] init];
        _pdfHttpServer.delegate = self;
    }
    
    return _pdfHttpServer;
}

@end
