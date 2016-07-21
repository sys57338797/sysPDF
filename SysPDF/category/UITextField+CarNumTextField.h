//
//  UITextField+PWDTextField.h
//  BaseMVVM
//
//  Created by suyushen on 15/8/7.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol CarNumTextFieldDelegate <NSObject>

@optional
- (void)CarNumTextField:(UITextField*)VNTextField getCNTextFieldTextWithFail:(const NSString*)failError;
- (void)CarNumTextField:(UITextField *)carNumTextField getIsSuccess:(BOOL)successed;

@end



@interface UITextField (CarNumTextField) <UITextFieldDelegate>

@property(nonatomic,assign) id<CarNumTextFieldDelegate> carNumDelegate;

- (void)initCarNumTextField;
- (NSString*)getCarNumTextFieldText;



@end
