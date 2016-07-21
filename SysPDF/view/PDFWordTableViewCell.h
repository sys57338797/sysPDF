//
//  CWordInfoCell.h
//  MuPDF
//
//  Created by mutouren on 9/16/13.
//
//

#import <UIKit/UIKit.h>

@class PDFWordTableViewCell;

@protocol PDFWordTableViewCellDelegate <NSObject>

- (void)PDFWordTableViewCellReloadDataWithCell:(PDFWordTableViewCell*)cell;

- (void)PDFWordTableViewCellPlaySoundClickWithCell:(PDFWordTableViewCell*)cell;

@end


@interface PDFWordTableViewCell : UITableViewCell

@property (nonatomic, assign) id<PDFWordTableViewCellDelegate> delegate;
@property (nonatomic, copy) NSString *chLabelText;
@property (nonatomic, assign) NSInteger indexPathRow;
@property (nonatomic, assign) NSInteger indexPathSection;

- (UILabel*)enLabel;
-(void)setENLabelText:(NSString*)text;
- (void)setENLabelAttributedText:(NSString *)text;
-(void)setCHLabelText:(NSString*)text;

@end
