//
//  UITextField+PWDTextField.m
//  BaseMVVM
//
//  Created by suyushen on 15/8/7.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//

#import "UITextField+CarNumTextField.h"
#import <objc/runtime.h>


@implementation UITextField (CarNumTextField)
static const int CARNUM_COUNT = 5;
static NSString const *CARNUM_ERROR_COUNT = @"车牌号必须为5位";
static NSString const *CARNUM_ERROR_CHECK = @"车牌号格式不正确";


void *CarNumDelegateKey = nil;

- (void)initCarNumTextField
{
//    self.delegate = self;
    [self addTarget:self action:@selector(carNumTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void) carNumTextFieldDidChange:(UITextField *) TextField{
    
    if (self.carNumDelegate&&[self.carNumDelegate respondsToSelector:@selector(CarNumTextField:getIsSuccess:)]) {
        [self.carNumDelegate CarNumTextField:self getIsSuccess:YES];
    }
}


- (void)setCarNumDelegate:(id<CarNumTextFieldDelegate>)carNumDelegate
{
    objc_setAssociatedObject(self, &CarNumDelegateKey, carNumDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<CarNumTextFieldDelegate>)carNumDelegate
{
    return objc_getAssociatedObject(self, &CarNumDelegateKey);
}

- (NSString*)getCarNumTextFieldText
{
    NSString *res = nil;
    NSString *text = [NSString stringWithFormat:@"%@",self.text];
    
    if (text.length != CARNUM_COUNT) {
        if (self.carNumDelegate&&[self.carNumDelegate respondsToSelector:@selector(CarNumTextField:getCNTextFieldTextWithFail:)]) {
            [self.carNumDelegate CarNumTextField:self getCNTextFieldTextWithFail:CARNUM_ERROR_COUNT];
        }
        
        return res;
    }
    
    BOOL b = [self checkCarNum:text];
    
    if (!b) {
        if (self.carNumDelegate&&[self.carNumDelegate respondsToSelector:@selector(CarNumTextField:getCNTextFieldTextWithFail:)]) {
            [self.carNumDelegate CarNumTextField:self getCNTextFieldTextWithFail:CARNUM_ERROR_CHECK];
        }
        
        return res;
    }
    
    res = [NSString stringWithFormat:@"%@",text];
    
    return res;
}

#pragma 正则匹配短信验证码数字组合       //^[A-Za-z0-9]+$
- (BOOL)checkCarNum:(NSString *) num
{
    NSString *pattern = @"^[A-Za-z0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:num];
    return isMatch;
    
}


#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return TRUE;
}

@end
