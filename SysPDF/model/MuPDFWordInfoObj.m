//
//  CWord.m
//  MuPDF
//
//  Created by mutouren on 7/11/13.
//
//

#import "MuPDFWordInfoObj.h"

@implementation MuPDFWordInfoObj


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.text = [aDecoder decodeObjectForKey:@"FZWordInfoObjText"];
        CGFloat x = [[aDecoder decodeObjectForKey:@"FZWordInfoObjRectOriginX"] floatValue];
        CGFloat y = [[aDecoder decodeObjectForKey:@"FZWordInfoObjRectOriginY"] floatValue];
        CGFloat w = [[aDecoder decodeObjectForKey:@"FZWordInfoObjRectOriginW"] floatValue];
        CGFloat h = [[aDecoder decodeObjectForKey:@"FZWordInfoObjRectOriginH"] floatValue];
        _rect.x0 = x;
        _rect.y0 = y;
        _rect.x1 = x+w;
        _rect.y1 = y+h;
        self.charLength = [[aDecoder decodeObjectForKey:@"FZWordInfoObjCharLength"] integerValue];
        self.spanIndex = [[aDecoder decodeObjectForKey:@"FZWordInfoObjSpanIndex"] integerValue];
        self.charIndex = [[aDecoder decodeObjectForKey:@"FZWordInfoObjCharIndex"] integerValue];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_text forKey:@"FZWordInfoObjText"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_rect.x0] forKey:@"FZWordInfoObjRectOriginX"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_rect.y0] forKey:@"FZWordInfoObjRectOriginY"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_rect.x1-_rect.x0] forKey:@"FZWordInfoObjRectOriginW"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_rect.y1-_rect.y0] forKey:@"FZWordInfoObjRectOriginH"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_charLength] forKey:@"FZWordInfoObjCharLength"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_spanIndex] forKey:@"FZWordInfoObjSpanIndex"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_charIndex] forKey:@"FZWordInfoObjCharIndex"];
}

@end
