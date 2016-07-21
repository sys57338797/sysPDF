//
//  CwordView.m
//  MuPDF
//
//  Created by mutouren on 9/9/13.
//
//

#import "PDFDocumentWordView.h"
#import <QuartzCore/QuartzCore.h>
#import "PureLayout.h"

#define FONTHEIGHT 15.0f

@interface PDFDocumentWordView ()

@property (nonatomic, strong) UILabel *enContentLabel;
@property (nonatomic, strong) UILabel *chContentLabel;
@property (nonatomic, strong) UILabel *propertyLabel;
@property (nonatomic, strong) UILabel *wainLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) NSArray *autoSubViewConstraint;

@end

@implementation PDFDocumentWordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5.0f;
        [self setBackgroundColor:[UIColor blackColor]];
        
        [self addSubview:self.enContentLabel];
        [self addSubview:self.chContentLabel];
        [self addSubview:self.propertyLabel];
        [self addSubview:self.wainLabel];
        [self addSubview:self.activityView];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

#pragma mark 设置英文内容
-(void)setEnContentLabelText:(NSString*)text
{
    [self.enContentLabel setText:text];
}

#pragma mark 返回英文内容
-(NSString*)getEnContentLabelText
{
    return self.enContentLabel.text;
}

#pragma mark 设置中文内容
-(void)setChContentLabelText:(NSString*)text
{
    [self.chContentLabel setText:text];
}

#pragma mark 设置属性内容
-(void)setPropertyLabelText:(NSString*)text
{
    [self.propertyLabel setText:text];
}

#pragma mark 设置提示信息
-(void) setWainLabelText:(NSString*)text
{
    if (self.wainLabel.isHidden) {
        [self.wainLabel setHidden:NO];
    }
    [self.wainLabel setText:text];
}

#pragma mark 刷新视图
-(void) refreshView
{
//    UILabel *enBel = (UILabel*)[self viewWithTag:CwordView_Label_ENContent];
//    UILabel *chBel = (UILabel*)[self viewWithTag:CwordView_Label_CHContent];
//    UILabel *proBel = (UILabel*)[self viewWithTag:CwordView_Label_Property];
//    UILabel *wainLabel = (UILabel*)[self viewWithTag:CwordView_Label_Wain];
//    UIActivityIndicatorView *activityView = (UIActivityIndicatorView*)[self viewWithTag:CwordView_UIActivityIndicatorView];
//    
//    CGSize enMaxSize = CGSizeMake(CGRectGetWidth(enBel.frame), 100000);
//    CGSize enSize = [enBel.text sizeWithFont:enBel.font constrainedToSize:enMaxSize];
//    enBel.numberOfLines = enSize.height/FONTHEIGHT;
//    enBel.frame = CGRectMake(CGRectGetMinX(enBel.frame), CGRectGetMinY(enBel.frame), CGRectGetWidth(enBel.frame), enSize.height);
//    
//    CGSize chMaxSize = CGSizeMake(CGRectGetWidth(chBel.frame), 100000);
//    CGSize chSize = [chBel.text sizeWithFont:chBel.font constrainedToSize:chMaxSize];
//    chBel.numberOfLines = chSize.height/FONTHEIGHT;
//    chBel.frame = CGRectMake(CGRectGetMinX(chBel.frame), CGRectGetMaxY(enBel.frame), CGRectGetWidth(chBel.frame), chSize.height);
//    
//    CGSize proMaxSize = CGSizeMake(CGRectGetWidth(proBel.frame), 100000);
//    CGSize proSize = [proBel.text sizeWithFont:proBel.font constrainedToSize:proMaxSize];
//    proBel.numberOfLines = proSize.height/FONTHEIGHT;
//    proBel.frame = CGRectMake(CGRectGetMinX(proBel.frame), CGRectGetMaxY(chBel.frame), CGRectGetWidth(proBel.frame), proSize.height);
//    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetMaxY(proBel.frame));
//    [wainLabel setCenter:CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2)];
//    [wainLabel setHidden:YES];
//    [activityView setCenter:CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2)];
}

#pragma mark 设置等待框是否等待
-(void) setActivityViewIsWait:(BOOL) wait
{
    if (wait) {
        [self setEnContentLabelText:@""];
        [self setChContentLabelText:@""];
        [self setPropertyLabelText:@""];
        [self refreshView];
        [self.activityView startAnimating];
    }
    else {
        [self.activityView stopAnimating];
    }
}

-(void)setHidden:(BOOL)hidden isAutoClose:(BOOL)isAuto
{
    [super setHidden:hidden];
    if (!hidden&&isAuto)
    {
        [self performSelector:@selector(closeView) withObject:nil afterDelay:3.0f];
    }
}

-(void)closeView
{
    [self setHidden:YES];
}

- (UILabel*)enContentLabel
{
    if (!_enContentLabel) {
        _enContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_enContentLabel setBackgroundColor:[UIColor clearColor]];
        [_enContentLabel setFont:[UIFont systemFontOfSize:14]];
        [_enContentLabel setTextColor:[UIColor whiteColor]];
    }
    
    return _enContentLabel;
}

- (UILabel*)chContentLabel
{
    if (!_chContentLabel) {
        _chContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_chContentLabel setBackgroundColor:[UIColor clearColor]];
        [_chContentLabel setFont:[UIFont systemFontOfSize:14]];
        [_chContentLabel setTextColor:[UIColor whiteColor]];
    }
    
    return _chContentLabel;
}

- (UILabel*)propertyLabel
{
    if (!_propertyLabel) {
        _propertyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_propertyLabel setBackgroundColor:[UIColor clearColor]];
        [_propertyLabel setFont:[UIFont systemFontOfSize:14]];
        [_propertyLabel setTextColor:[UIColor whiteColor]];
    }
    
    return _propertyLabel;
}

- (UILabel*)wainLabel
{
    if (!_wainLabel) {
        _wainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_wainLabel setBackgroundColor:[UIColor clearColor]];
        [_wainLabel setFont:[UIFont systemFontOfSize:14]];
        [_wainLabel setTextColor:[UIColor redColor]];
        [_wainLabel setHidden:YES];
    }
    
    return _wainLabel;
}

- (UIActivityIndicatorView*)activityView
{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _activityView;
}

- (void)updateConstraints
{
    [self.enContentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.chContentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    if (self.autoSubViewConstraint) {
        [self.autoSubViewConstraint autoRemoveConstraints];
    }
    
    self.autoSubViewConstraint = [NSLayoutConstraint autoCreateConstraintsWithoutInstalling:^{
        
    }];
    
    [self.autoSubViewConstraint autoInstallConstraints];
    
    [super updateConstraints];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
