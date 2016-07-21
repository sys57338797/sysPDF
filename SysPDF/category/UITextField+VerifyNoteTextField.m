//
//  UITextField+PWDTextField.m
//  BaseMVVM
//
//  Created by suyushen on 15/8/7.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//

#import "UITextField+VerifyNoteTextField.h"
#import <objc/runtime.h>


@implementation UITextField (VerifyNoteTextField)
static const int VERIFY_COUNT_MAX = 6;
static const int VERIFY_COUNT_MIN = 4;
static NSString const *VERIFY_ERROR_COUNT_MIN = @"短信验证码不能小于4位";
static NSString const *VERIFY_ERROR_COUNT_MAX = @"短信验证码不能大于6位";
static NSString const *VERIFY_ERROR_CHECK = @"短信验证码格式不正确";


void *VerifyNoteDelegateKey = nil;

- (void)initVerifyNoteTextField
{
//    self.delegate = self;
    
    [self addTarget:self action:@selector(verifyNoteTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void) verifyNoteTextFieldDidChange:(UITextField *) TextField{
    
    if (self.verifyNoteDelegate&&[self.verifyNoteDelegate respondsToSelector:@selector(VerifyNoteTextField:getIsSuccess:)]) {
        [self.verifyNoteDelegate VerifyNoteTextField:self getIsSuccess:YES];
    }
}

- (void)setVerifyNoteDelegate:(id<VerifyNoteTextFieldDelegate>)verifyNoteDelegate
{
    objc_setAssociatedObject(self, &VerifyNoteDelegateKey, verifyNoteDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<VerifyNoteTextFieldDelegate>)verifyNoteDelegate
{
    return objc_getAssociatedObject(self, &VerifyNoteDelegateKey);
}

- (NSString*)getVerifyNoteTextFieldText
{
    NSString *res = nil;
    NSString *text = [NSString stringWithFormat:@"%@",self.text];
    
    if (text.length < VERIFY_COUNT_MIN) {
        if (self.verifyNoteDelegate&&[self.verifyNoteDelegate respondsToSelector:@selector(VerifyNoteTextField:getVNTextFieldTextWithFail:)]) {
            [self.verifyNoteDelegate VerifyNoteTextField:self getVNTextFieldTextWithFail:VERIFY_ERROR_COUNT_MIN];
        }
        
        return res;
    }
    
    if (text.length > VERIFY_COUNT_MAX) {
        if (self.verifyNoteDelegate&&[self.verifyNoteDelegate respondsToSelector:@selector(VerifyNoteTextField:getVNTextFieldTextWithFail:)]) {
            [self.verifyNoteDelegate VerifyNoteTextField:self getVNTextFieldTextWithFail:VERIFY_ERROR_COUNT_MAX];
        }
        
        return res;
    }
    
    BOOL b = [self checkNote:text];
    
    if (!b) {
        if (self.verifyNoteDelegate&&[self.verifyNoteDelegate respondsToSelector:@selector(VerifyNoteTextField:getVNTextFieldTextWithFail:)]) {
            [self.verifyNoteDelegate VerifyNoteTextField:self getVNTextFieldTextWithFail:VERIFY_ERROR_CHECK];
        }
        
        return res;
    }
    
    res = [NSString stringWithFormat:@"%@",text];
    
    return res;
}

#pragma 正则匹配短信验证码数字组合       //^[A-Za-z0-9]+$
- (BOOL)checkNote:(NSString *) note
{
    NSString *pattern = @"^[0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:note];
    return isMatch;
    
}


#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return TRUE;
}

@end
