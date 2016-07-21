//
//  CwordView.h
//  MuPDF
//
//  Created by mutouren on 9/9/13.
//
//

#import <UIKit/UIKit.h>


@interface PDFDocumentWordView : UIView


#pragma mark 设置英文内容
-(void)setEnContentLabelText:(NSString*)text;
#pragma mark 返回英文内容
-(NSString*)getEnContentLabelText;
#pragma mark 设置中文内容
-(void)setChContentLabelText:(NSString*)text;
#pragma mark 设置属性内容
-(void)setPropertyLabelText:(NSString*)text;
#pragma mark 刷新视图
-(void) refreshView;
#pragma mark 设置等待框是否等待
-(void) setActivityViewIsWait:(BOOL) wait;
#pragma mark 设置提示信息
-(void) setWainLabelText:(NSString*)text;
#pragma mark 设置是否显示
-(void)setHidden:(BOOL)hidden isAutoClose:(BOOL)isAuto;

@end
