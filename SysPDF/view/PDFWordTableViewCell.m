//
//  CWordInfoCell.m
//  MuPDF
//
//  Created by mutouren on 9/16/13.
//
//

#import "PDFWordTableViewCell.h"
#import "PureLayout.h"
#import "UILabel+textSize.h"

@interface PDFWordTableViewCell ()

@property (nonatomic, strong) UIImageView *bgImageView;     //背景
@property (nonatomic, strong) UILabel *enLabel;             //英文label
@property (nonatomic, strong) UILabel *chLabel;             //中文label
//@property (nonatomic, strong) UILabel *phoneticLabel;       //音译label
@property (nonatomic, strong) UIImageView *soundImageView;  //声音imageView;
@property (nonatomic, strong) UIButton *addContrastBtn;     //加入对比按钮
@property (nonatomic, strong) UIImageView *HLineView;       //横线
@property (nonatomic, strong) UIImageView *VLineView;       //竖线

@property (nonatomic, strong) NSArray *autoSubViewConstraint;

@end

@implementation PDFWordTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.contentView addSubview:self.bgImageView];
        
        [self.bgImageView addSubview:self.enLabel];
        [self.bgImageView addSubview:self.chLabel];
//        [self.bgImageView addSubview:self.phoneticLabel];
//        [self.bgImageView addSubview:self.annotationBtn];
        [self.bgImageView addSubview:self.soundImageView];
        [self.bgImageView addSubview:self.HLineView];
        [self.bgImageView addSubview:self.VLineView];
        [self.bgImageView addSubview:self.addContrastBtn];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel*)enLabel
{
    if (!_enLabel) {
        _enLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_enLabel setBackgroundColor:[UIColor clearColor]];
        [_enLabel setTextColor:[UIColor blackColor]];
        [_enLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [_enLabel setNumberOfLines:2];
    }
    
    return _enLabel;
}

- (UILabel*)chLabel
{
    if (!_chLabel) {
        _chLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_chLabel setBackgroundColor:[UIColor clearColor]];
        [_chLabel setTextColor:RGBA(163, 186, 210, 1.0f)];
        [_chLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [_chLabel setUserInteractionEnabled:YES];
        [_chLabel setNumberOfLines:0];
        
        UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chLabelClick:)];
        //点击的次数
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        
        [_chLabel addGestureRecognizer:singleRecognizer];
    }
    
    return _chLabel;
}

//- (UILabel*)phoneticLabel
//{
//    if (!_phoneticLabel) {
//        _phoneticLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        [_phoneticLabel setTextAlignment:NSTextAlignmentRight];
//        [_phoneticLabel setBackgroundColor:[UIColor clearColor]];
//        [_phoneticLabel setTextColor:[UIColor blackColor]];
//        [_phoneticLabel setFont:[UIFont systemFontOfSize:14.0f]];
//    }
//    
//    return _phoneticLabel;
//}

- (UIImageView*)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *bgImage = [UIImage imageNamed:@"word_cell_bg.png"];
        bgImage = [bgImage stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        [_bgImageView setImage:bgImage];
        [_bgImageView setUserInteractionEnabled:YES];
        [_bgImageView setBackgroundColor:[UIColor clearColor]];
    }
    
    return _bgImageView;
}

- (UIImageView*)VLineView
{
    if (!_VLineView) {
        _VLineView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_VLineView setBackgroundColor:RGBA(163, 186, 210, 1.0f)];
    }
    
    return _VLineView;
}

- (UIImageView*)HLineView
{
    if (!_HLineView) {
        _HLineView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_HLineView setBackgroundColor:RGBA(163, 186, 210, 1.0f)];
    }
    
    return _HLineView;
}

//- (UIButton*)annotationBtn
//{
//    if (!_annotationBtn) {
//        _annotationBtn = [[UIButton alloc] initWithFrame:CGRectZero];
//        [_annotationBtn setBackgroundColor:[UIColor clearColor]];
//        [_annotationBtn setTitle:@"注释" forState:UIControlStateNormal];
//        [_annotationBtn addTarget:self action:@selector(annotationBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    return _annotationBtn;
//}

- (UIButton*)addContrastBtn
{
    if (!_addContrastBtn) {
        _addContrastBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_addContrastBtn setBackgroundColor:[UIColor clearColor]];
        [_addContrastBtn setImage:[UIImage imageNamed:@"cell_btn_add.png"] forState:UIControlStateNormal];
        [_addContrastBtn setImage:[UIImage imageNamed:@"cell_btn_subtract.png"] forState:UIControlStateSelected];
        [_addContrastBtn addTarget:self action:@selector(addContrastBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _addContrastBtn;
}

- (UIImageView*)soundImageView
{
    if (!_soundImageView) {
        _soundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_soundImageView setBackgroundColor:[UIColor clearColor]];
        [_soundImageView setImage:[UIImage imageNamed:@"word_cell_sound_btn_nor.png"]];
        [_soundImageView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(soundImageViewClick:)];
        //点击的次数
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        
        [_soundImageView addGestureRecognizer:singleRecognizer];
    }
    
    return _soundImageView;
}

-(void)setENLabelText:(NSString*)text
{
    [self.enLabel setText:text];
    
}

- (void)setENLabelAttributedText:(NSString *)text
{
    NSArray *twoArray = [text componentsSeparatedByString:@"\r\n"];
    NSArray *oneArray = [text componentsSeparatedByString:@"  "];
    
    if (twoArray.count > 1 || oneArray.count > 1) {
        NSMutableAttributedString *butString = [[NSMutableAttributedString alloc] initWithString:text];
        NSString *subString = nil;
        
        if (twoArray.count > 1) {
            subString = [twoArray objectAtIndex:0];
        }
        else if (oneArray.count > 1) {
            subString = [oneArray objectAtIndex:0];
        }
        else {
            return;
        }
        
        [butString addAttributes:@{NSForegroundColorAttributeName:RGBA(163, 186, 210, 1.0f),NSFontAttributeName:[UIFont systemFontOfSize:20.0f]} range:NSMakeRange(0,subString.length+2)];
        [butString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:16.0f]} range:NSMakeRange(subString.length+2,text.length-subString.length-2)];
        [self.enLabel setAttributedText:butString];
    }
}

-(void)setCHLabelText:(NSString*)text
{
    [self.chLabel setText:text];
}

- (void)addContrastBtnClick
{
    [self.addContrastBtn setSelected:!self.addContrastBtn.isSelected];
}

- (void)soundImageViewClick:(id)sender
{
    if (self.soundImageView.isAnimating) {
        [self.soundImageView stopAnimating];
        [self.soundImageView setImage:[UIImage imageNamed:@"word_cell_sound_btn_nor.png"]];
    }
    else {
        [self.soundImageView setAnimationImages:@[[UIImage imageNamed:@"word_cell_sound_btn_playing001.png"],[UIImage imageNamed:@"word_cell_sound_btn_playing002.png"],[UIImage imageNamed:@"word_cell_sound_btn_playing003.png"]]];
        [self.soundImageView setAnimationDuration:1.0f];
        [self.soundImageView setAnimationRepeatCount:1];
        [self.soundImageView startAnimating];
    }
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(PDFWordTableViewCellPlaySoundClickWithCell:)]) {
        [self.delegate PDFWordTableViewCellPlaySoundClickWithCell:self];
    }
}

- (void)chLabelClick:(id)sender
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(PDFWordTableViewCellReloadDataWithCell:)]) {
        [self.delegate PDFWordTableViewCellReloadDataWithCell:self];
    }
}

- (void)setAddContrastBtnImage:(UIImage*)image
{
    [self.addContrastBtn setImage:image forState:UIControlStateNormal];
}

- (void)updateConstraints
{
    
    if (self.autoSubViewConstraint) {
        [self.autoSubViewConstraint autoRemoveConstraints];
    }
    
    self.autoSubViewConstraint = [NSLayoutConstraint autoCreateConstraintsWithoutInstalling:^{
        CGFloat bgGap = 8.0f;
        [self.bgImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:bgGap];
        [self.bgImageView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:bgGap];
        [self.bgImageView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:bgGap];
        
        CGFloat gap = 6.0f;
        CGFloat viewGap = 12.0f;
        [self.enLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:viewGap];
        [self.enLabel autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.VLineView withOffset:-gap];
        [self.enLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:gap];
        
        [self.soundImageView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:viewGap];
        [self.soundImageView autoSetDimensionsToSize:self.soundImageView.image.size];
        
        [self.VLineView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:1.0f];
        [self.VLineView autoSetDimension:ALDimensionWidth toSize:1.0f];
        [self.VLineView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.soundImageView withOffset:-gap];
        [self.VLineView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.HLineView];
        
        [@[self.enLabel,self.soundImageView] autoAlignViewsToAxis:ALAxisHorizontal];
        
        [self.HLineView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:1.0f];
        [self.HLineView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:1.0f];
        [self.HLineView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.enLabel withOffset:gap];
        [self.HLineView autoSetDimension:ALDimensionHeight toSize:1.0f];
        
        [self.chLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.HLineView withOffset:gap];
        [self.chLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.enLabel];
        [self.chLabel autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.addContrastBtn withOffset:-gap];
//        [self.chLabel autoSetDimension:ALDimensionHeight toSize:23.0f relation:NSLayoutRelationGreaterThanOrEqual];
        
        [self.addContrastBtn autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.soundImageView];
        [self.addContrastBtn autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.chLabel];
        [self.addContrastBtn autoSetDimensionsToSize:self.addContrastBtn.currentImage.size];
        
        [self.bgImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.chLabel withOffset:bgGap];
        [self.bgImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:bgGap];
    }];
    
    [self.autoSubViewConstraint autoInstallConstraints];
    
    [super updateConstraints];
}


@end
