//
//  PDFWordWebAnnotationCell.m
//  SysPDF
//
//  Created by mutouren on 3/24/16.
//  Copyright © 2016 suyushen. All rights reserved.
//

#import "PDFWordWebAnnotationCell.h"
#import "PureLayout.h"
#import "UILabel+textSize.h"

@interface PDFWordWebAnnotationCell ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *enLabel;
@property (nonatomic, strong) UILabel *chLabel;

@property (nonatomic, strong) NSArray *autoSubViewConstraint;

@end

@implementation PDFWordWebAnnotationCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.contentView addSubview:self.bgImageView];
        [self.bgImageView addSubview:self.enLabel];
        [self.bgImageView addSubview:self.chLabel];
    }
    return self;
}

- (void)setEnLabelText:(NSString*)text
{
    [self.enLabel setText:text];
}

- (void)setChLabelText:(NSString*)text
{
    [self.chLabel setText:text];
}

- (void)updateConstraints
{
    [self.bgImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.enLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.chLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if (self.autoSubViewConstraint) {
        [self.autoSubViewConstraint autoRemoveConstraints];
    }
    
    self.autoSubViewConstraint = [NSLayoutConstraint autoCreateConstraintsWithoutInstalling:^{
        
        [self.bgImageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.bgImageView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:6.0f];
        [self.bgImageView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:6.0f];
        [self.bgImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
    }];
    
    [self.autoSubViewConstraint autoInstallConstraints];
    
    [super updateConstraints];
}

- (UILabel*)chLabel
{
    if (!_chLabel) {
        _chLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_chLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_chLabel setTextColor:[UIColor blackColor]];
        [_chLabel setNumberOfLines:1];
    }
    
    return _chLabel;
}

- (UILabel*)enLabel
{
    if (!_enLabel) {
        _enLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_enLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_enLabel setTextColor:[UIColor grayColor]];
        [_enLabel setNumberOfLines:2];
    }
    
    return _enLabel;
}

- (UIImageView*)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *bgImage = [UIImage imageNamed:@"webannotationcell_bg.png"];
        bgImage = [bgImage stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f];
        [_bgImageView setImage:bgImage];
    }
    
    return _bgImageView;
}

@end
