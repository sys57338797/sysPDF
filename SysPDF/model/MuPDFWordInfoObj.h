//
//  CWord.h
//  MuPDF
//
//  Created by mutouren on 7/11/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MuPDF/fitz.h>


@interface MuPDFWordInfoObj : NSObject


@property (nonatomic) fz_rect rect;                 //词矩形
@property (nonatomic,retain) NSString *text;        //内容
@property (nonatomic) NSInteger charLength;         //词长度
@property (nonatomic) NSInteger spanIndex;
@property (nonatomic) NSInteger charIndex;
@end
