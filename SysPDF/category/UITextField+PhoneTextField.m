//
//  UITextField+PWDTextField.m
//  BaseMVVM
//
//  Created by suyushen on 15/8/7.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//

#import "UITextField+PhoneTextField.h"
#import <objc/runtime.h>


@implementation UITextField (PhoneTextField)
static const int PHONE_COUNT = 11;
static NSString const *PHONE_ERROR_COUNT = @"手机号码需要11位";
static NSString const *PHONE_ERROR_CHECK = @"手机号码格式不正确";


void *phoneDelegateKey = nil;

- (void)initPhoneTextField
{
//    self.delegate = self;
    
    [self addTarget:self action:@selector(phoneTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void) phoneTextFieldDidChange:(UITextField *) TextField{
    
    if (self.phoneDelegate&&[self.phoneDelegate respondsToSelector:@selector(PhoneTextField:getIsSuccess:)]) {
        [self.phoneDelegate PhoneTextField:self getIsSuccess:YES];
    }
}

- (void)setPhoneDelegate:(id<PhoneTextFieldDelegate>)phoneDelegate
{
    objc_setAssociatedObject(self, &phoneDelegateKey, phoneDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<PhoneTextFieldDelegate>)phoneDelegate
{
    return objc_getAssociatedObject(self, &phoneDelegateKey);
}

- (NSString*)getPhoneTextFieldText
{
    NSString *res = nil;
    NSString *text = [NSString stringWithFormat:@"%@",self.text];
    
    if (text.length != PHONE_COUNT) {
        if (self.phoneDelegate&&[self.phoneDelegate respondsToSelector:@selector(PhoneTextField:getPhoneTextFieldTextWithFail:)]) {
            [self.phoneDelegate PhoneTextField:self getPhoneTextFieldTextWithFail:PHONE_ERROR_COUNT];
        }
        
        return res;
    }
    
    BOOL b = [self checkTelNumber:text];
    
    if (!b) {
        if (self.phoneDelegate&&[self.phoneDelegate respondsToSelector:@selector(PhoneTextField:getPhoneTextFieldTextWithFail:)]) {
            [self.phoneDelegate PhoneTextField:self getPhoneTextFieldTextWithFail:PHONE_ERROR_CHECK];
        }
        
        return res;
    }
    
    res = [NSString stringWithFormat:@"%@",text];
    
    return res;
}

#pragma 正则匹配手机号
- (BOOL)checkTelNumber:(NSString *) telNumber
{
    NSString *pattern = @"^(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:telNumber];
    return isMatch;
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    
    return TRUE;
}

@end
