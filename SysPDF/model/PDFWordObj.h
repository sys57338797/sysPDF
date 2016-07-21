//
//  CWord.h
//  MuPDF
//
//  Created by mutouren on 7/11/13.
//
//

#import <Foundation/Foundation.h>


typedef enum {
    PDFWordObjWordTypeABJ =2222,           //形容词
    PDFWordObjWordTypeADV,                 //副词
    PDFWordObjWordTypeCONJ,                //连接词
    PDFWordObjWordTypeN,                   //名词
    PDFWordObjWordTypeV,                   //动词
    PDFWordObjWordTypeVI,                  //不及物动词
    PDFWordObjWordTypeVT,                  //及物动词
    PDFWordObjWordTypePAST,                //过去分词
    PDFWordObjWordTypePRES,                //现在分词
    PDFWordObjWordTypePREP,                //介词
} PDFWordObjWordType;



@interface PDFWordObj : NSObject



@property (nonatomic, strong) NSMutableArray *CHContentArray;           //有道注释 (数组存放 字典，key为词类型，value为翻译)
@property (nonatomic, copy) NSString *ENContent;                        //英文
@property (nonatomic) long clickCount;                                  //点击次数
@property (nonatomic, copy) NSString *ukPhonetic;                       //英式音标
@property (nonatomic, copy) NSString *CHContent;                        //中文
@property (nonatomic, strong) NSMutableArray *webCHContentArray;        //网络注释
@property (nonatomic, assign) BOOL isShowAnnotation;                    //是否显示注释
@property (nonatomic, copy) NSString *annotation;                       //注释


+ (id)objWithDictionary:(NSDictionary*)dic;

@end
