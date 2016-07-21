//
//  PDFWordTableViewController.m
//  MuPDF
//
//  Created by mutouren on 9/12/13.
//
//

#import "PDFWordTableViewController.h"
#import "PDFManager.h"
#import "PDFWordTableViewCell.h"
#import "PDFWordObj.h"
#import "PureLayout.h"
#import "TopTabBarViewController.h"
#import "UILabel+textSize.h"
#import "CAIFlySpeechManager.h"
#import "CADataCacheManager.h"


@interface PDFWordTableViewController () <PDFWordTableViewCellDelegate>

@property (nonatomic, strong) TopTabBarViewController *topTabBarController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PDFWordTableViewCell *tableViewCell;

@property (nonatomic, strong) NSMutableDictionary *wordDictionary;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation PDFWordTableViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    
    return self;
}

- (void)initData
{
    self.wordDictionary = [NSMutableDictionary dictionaryWithDictionary:[[CADataCacheManager shareInstance] getAllWordDictionary]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)refreshCell:(PDFWordTableViewCell*)cell Obj:(PDFWordObj*)obj
{
    
    NSString *enText = [NSString stringWithFormat:@"%@   %@",obj.ENContent,obj.ukPhonetic];
    [cell setENLabelText:enText];
    if (cell.enLabel.textLineCount > 1) {
        enText = [NSString stringWithFormat:@"%@\r\n%@",obj.ENContent,obj.ukPhonetic];
    }
    
    [cell setENLabelAttributedText:enText];
    
    NSString *chText = @"";
    if (obj.isShowAnnotation) {
        chText = [obj.annotation copy];
    }
    else {
        NSMutableString *MutableChText = [NSMutableString stringWithFormat:@""];
        for (NSString *ch in obj.CHContentArray) {
            [MutableChText appendFormat:@"%@\r\n",ch];
        }
        
        if (MutableChText.length > 0) {
            [MutableChText deleteCharactersInRange:NSMakeRange(MutableChText.length-2, 2)];
        }
        
        chText = [MutableChText copy];
    }
    
    
    [cell setCHLabelText:chText];
}

- (NSArray*)secationNameArray
{
    return [self.wordDictionary allKeys];
}

- (PDFWordObj*)getPDFObjWithSection:(NSInteger)section row:(NSInteger)row
{
    PDFWordObj *obj = nil;
    NSString *key = [[self secationNameArray] objectAtIndex:section];
    NSMutableArray *dataArray = [self.wordDictionary objectForKey:key];
    
    if (dataArray && dataArray.count < row) {
        obj = [dataArray objectAtIndex:row];
    }
    
    return obj;
}

#pragma mark - Table view data source
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self secationNameArray];
}

//section （标签）标题显示
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self secationNameArray] objectAtIndex:section];
}

//标签数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self secationNameArray].count;
}

// 设置section的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25;
}

//点击右侧索引表项时调用
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSString *key = [[self secationNameArray] objectAtIndex:index];
    NSLog(@"sectionForSectionIndexTitle key=%@",key);
    if (key == UITableViewIndexSearch) {
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    return index;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectZero];
    title.text = [NSString stringWithFormat:@"  %@",[[self secationNameArray] objectAtIndex:section]];
    title.textColor=[UIColor grayColor];
    title.font = [UIFont systemFontOfSize:15];
    title.backgroundColor = [UIColor whiteColor];
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = [self secationNameArray];
    NSString *key = [sectionArray objectAtIndex:section];
    NSMutableArray *dataArray = [self.wordDictionary objectForKey:key];
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"PDFWordTableViewCell";
    PDFWordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PDFWordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.indexPathSection = indexPath.section;
    cell.indexPathRow = indexPath.row;
    
    PDFWordObj *obj = [self getPDFObjWithSection:indexPath.section row:indexPath.row];
    if (obj) {
        [self refreshCell:cell Obj:obj];
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PDFWordObj *obj = [self getPDFObjWithSection:indexPath.section row:indexPath.row];
    if (obj) {
        [self refreshCell:self.tableViewCell Obj:obj];
        
        [self.tableViewCell layoutIfNeeded];
        [self.tableViewCell updateConstraintsIfNeeded];
    }
    
    CGFloat cellH = [self.tableViewCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return cellH;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PDFWordObj *obj = [self getPDFObjWithSection:indexPath.section row:indexPath.row];
    if (obj) {
        
    }
}

#pragma mark PDFWordTableViewCellDelegate
- (void) PDFWordTableViewCellReloadDataWithCell:(PDFWordTableViewCell*)cell
{
    PDFWordObj *obj = [self getPDFObjWithSection:cell.indexPathSection row:cell.indexPathRow];
    if (obj) {
        obj.isShowAnnotation = !obj.isShowAnnotation;
    }
    
    [self.tableView reloadData];
}

- (void)PDFWordTableViewCellPlaySoundClickWithCell:(PDFWordTableViewCell*)cell
{
    PDFWordObj *obj = [self getPDFObjWithSection:cell.indexPathSection row:cell.indexPathRow];
    if (obj) {
        [[CAIFlySpeechManager shareInstance] playMsg:obj.ENContent];
    }
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 60.0f;
    }
    
    return _tableView;
}

- (PDFWordTableViewCell*)tableViewCell
{
    if (!_tableViewCell) {
        _tableViewCell = [[PDFWordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    }
    
    return _tableViewCell;
}

@end
