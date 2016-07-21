//
//  PDFFilesViewController.m
//  MuPDF
//
//  Created by mutouren on 7/2/13.
//
//

#import "PDFFilesViewController.h"
#import "PDFManager.h"
#import "PDFDocumentController.h"
#import "UIViewController+Factory.h"
#import "NavManager.h"
#import "CADataCacheManager.h"
#import "PDFBookObj.h"
#import "PureLayout.h"


@interface PDFFilesViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation PDFFilesViewController


- (id)init
{
    self = [super init];
    if (self) {
        
        self.dataArray = [NSMutableArray array];
        
    }
    
    return self;
}

-(void)initData
{
    self.dataArray = [CADataCacheManager shareInstance].PDFFileNameArray;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
    [self.view setNeedsUpdateConstraints];
    
    [self initData];
    
    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PDFFilesTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PDFBookObj *obj = [_dataArray objectAtIndex:indexPath.row];
    // Configure the cell...
    [cell.textLabel setText:obj.bookName];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PDFBookObj *obj = [_dataArray objectAtIndex:indexPath.row];
    
    [PDFManager shareInstance].openObj = obj;
    BOOL isOpen = [[PDFManager shareInstance] initDocument];
    if (isOpen) {
        [PDFManager shareInstance].openObj = obj;
        UIViewController *document = [UIViewController CreateControllerWithTag:CtrlTag_PDFDocument];
//        [[NavManager shareInstance] setOrietation:UIInterfaceOrientationMaskLandscapeLeft];
        [[NavManager shareInstance] showViewController:document isAnimated:YES];
        return;
    }
    
    UIAlertView *aView = [[UIAlertView alloc] initWithTitle:@"PDF" message:[PDFManager shareInstance].error delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    aView.delegate = self;
    [aView show];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

- (void)updateViewConstraints
{
    if (!self.didSetupConstraints) {
        
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        self.didSetupConstraints = TRUE;
    }
    
    [super updateViewConstraints];
}


- (UITableView*)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 45.0f;
    }
    
    return _tableView;
}

@end
