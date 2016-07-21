//
//  UILabel+textHeight.m
//  CWGJCarOwner
//
//  Created by mutouren on 12/8/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "UILabel+textSize.h"

@implementation UILabel (textSize)


- (CGFloat)textHeight
{
    CGFloat width = self.frame.size.width;
//    if (!self.translatesAutoresizingMaskIntoConstraints) {
//        for (NSLayoutConstraint *constraint in self.constraints) {
//            if (constraint.firstAttribute == NSLayoutAttributeWidth) {
//                width = constraint.constant;
//                break;
//            }
//        }
//    }
    
    return [self.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:self.font}
                                   context:nil].size.height;
}

- (CGFloat)attributedTextHeight
{
    return [self.attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                             context:nil].size.height;
}

- (int)textLineCount
{
    CGFloat oneH = [self textALineHeight];
    CGFloat moreH = [self textHeight];
    
    return moreH/oneH;
}

- (CGFloat)textALineWidth
{
    return [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}].width;
}

- (CGFloat)textALineHeight
{
    return [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}].height;
}

@end
