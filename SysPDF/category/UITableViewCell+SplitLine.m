//
//  UITableViewCell+SplitLine.m
//  CWGJCarOwner
//
//  Created by mac on 16/3/2.
//  Copyright © 2016年 mutouren. All rights reserved.
//

#import "UITableViewCell+SplitLine.h"
#import "PureLayout.h"

@implementation UITableViewCell (SplitLine)

- (void)addDefaultSplitLine
{
    UIView* line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [self addSubview:line];
    
    [line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:8];
    [line autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:8];
    [line autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [line autoSetDimension:ALDimensionHeight toSize:1];
}

@end
