//
//  UITextField+PWDTextField.h
//  BaseMVVM
//
//  Created by suyushen on 15/8/7.
//  Copyright (c) 2015年 suyushen. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol VerifyNoteTextFieldDelegate <NSObject>

@optional
- (void)VerifyNoteTextField:(UITextField*)VNTextField getVNTextFieldTextWithFail:(const NSString*)failError;
- (void)VerifyNoteTextField:(UITextField *)verifyNoteTextField getIsSuccess:(BOOL)successed;
@end



@interface UITextField (VerifyNoteTextField) <UITextFieldDelegate>

@property(nonatomic,assign) id<VerifyNoteTextFieldDelegate> verifyNoteDelegate;

- (void)initVerifyNoteTextField;
- (NSString*)getVerifyNoteTextFieldText;



@end
