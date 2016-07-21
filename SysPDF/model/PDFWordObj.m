//
//  CWord.m
//  MuPDF
//
//  Created by mutouren on 7/11/13.
//
//

#import "PDFWordObj.h"


NSString *const kPDFWordObjCHContentArray = @"kPDFWordObjCHContentArray";
NSString *const kPDFWordObjENContent = @"kPDFWordObjENContent";
NSString *const kPDFWordObjCHContent = @"kPDFWordObjCHContent";
NSString *const kPDFWordObjClickCount = @"kPDFWordObjClickCount";
NSString *const kPDFWordObjwebCHContentArray = @"kPDFWordObjwebCHContentArray";
NSString *const kPDFWordObjwebUkPhonetic = @"kPDFWordObjwebUkPhonetic";



@implementation PDFWordObj


#pragma mark 基本类型的字典初始化函数
+ (id)objWithDictionary:(NSDictionary*)dic;
{
    PDFWordObj *obj = [[PDFWordObj alloc] init];

    obj.ENContent = [dic objectForKey:@"query"];
    obj.CHContent = [dic objectForKey:@"translation"];
    
    obj.webCHContentArray = [dic objectForKey:@"web"];
    
    NSDictionary *basic = [dic objectForKey:@"basic"];
    obj.CHContentArray = [basic objectForKey:@"explains"];
    obj.ukPhonetic = [NSString stringWithFormat:@"/%@/",[basic objectForKey:@"uk-phonetic"]];
    obj.annotation = @"注释";
    obj.isShowAnnotation = NO;
    obj.clickCount = 1;
    return obj;
}

-(id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.CHContentArray = [aDecoder decodeObjectForKey:kPDFWordObjCHContentArray];
        self.clickCount = [[aDecoder decodeObjectForKey:kPDFWordObjClickCount] integerValue];
        self.webCHContentArray = [aDecoder decodeObjectForKey:kPDFWordObjwebCHContentArray];
        self.ENContent = [aDecoder decodeObjectForKey:kPDFWordObjENContent];
        self.CHContent = [aDecoder decodeObjectForKey:kPDFWordObjCHContent];
        self.ukPhonetic = [aDecoder decodeObjectForKey:kPDFWordObjwebUkPhonetic];
        self.annotation = @"注释";
        self.isShowAnnotation = NO;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.CHContentArray forKey:kPDFWordObjCHContentArray];
    [aCoder encodeObject:[NSNumber numberWithLong:self.clickCount] forKey:kPDFWordObjClickCount];
    [aCoder encodeObject:self.webCHContentArray forKey:kPDFWordObjwebCHContentArray];
    [aCoder encodeObject:self.ENContent forKey:kPDFWordObjENContent];
    [aCoder encodeObject:self.CHContent forKey:kPDFWordObjCHContent];
    [aCoder encodeObject:self.ukPhonetic forKey:kPDFWordObjwebUkPhonetic];
}

@end
