//
//  UIImage+color.m
//  CWGJMerchant
//
//  Created by mac on 15/9/16.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "UIImage+color.h"

@implementation UIImage (color)


+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return pressedColorImg;
}

@end
