//
//  UIImageView+rotation.m
//  CWGJCarOwner
//
//  Created by hua on 16/2/26.
//  Copyright © 2016年 mutouren. All rights reserved.
//

#import "UIImageView+rotation.h"
#import <objc/runtime.h>

@implementation UIImageView (rotation)

-(void)rotation {
//    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//    rotation.duration = 3.6f;
//    rotation.repeatCount = HUGE_VALF;
//    rotation.fromValue = [NSNumber numberWithFloat:0];
//    rotation.toValue = [NSNumber numberWithFloat:(M_PI*2)];
//    [self.layer addAnimation:rotation forKey:@"rotation"];
    
    if (self.isAnimate) {
        return;
    }
    self.isAnimate = YES;
    
    [self rotationLoop];
}

- (void)rotationLoop
{
    [UIView animateWithDuration:0.9f delay:0.0f options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.transform = CGAffineTransformRotate(self.transform, M_PI_2);
                     }
                     completion:^(BOOL finished){
                         [self rotationLoop];
                     }
     ];
}

- (BOOL)isAnimate
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsAnimate:(BOOL)isAnimate
{
    objc_setAssociatedObject(self, @selector(isAnimate), [NSNumber numberWithBool:isAnimate], OBJC_ASSOCIATION_ASSIGN);
}


@end
