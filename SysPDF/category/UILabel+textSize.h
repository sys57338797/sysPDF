//
//  UILabel+textHeight.h
//  CWGJCarOwner
//
//  Created by mutouren on 12/8/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (textSize)

#pragma mark label内容的高度
- (CGFloat)textHeight;

#pragma mark label attributedText的高度
- (CGFloat)attributedTextHeight;

#pragma mark label 1行的text宽度
- (CGFloat)textALineWidth;

#pragma mark label 1行的text高度
- (CGFloat)textALineHeight;

#pragma mark label 内容的行数
- (int)textLineCount;

@end
