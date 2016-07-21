//
//  UITextField+PWDTextField.h
//  BaseMVVM
//
//  Created by suyushen on 15/8/7.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol PhoneTextFieldDelegate <NSObject>

@optional
- (void)PhoneTextField:(UITextField*)phoneTextField getPhoneTextFieldTextWithFail:(const NSString*)failError;
- (void)PhoneTextField:(UITextField *)phoneTextField getIsSuccess:(BOOL)successed;

@end



@interface UITextField (PhoneTextField) <UITextFieldDelegate>

@property(nonatomic,assign) id<PhoneTextFieldDelegate> phoneDelegate;

- (void)initPhoneTextField;
- (NSString*)getPhoneTextFieldText;



@end
