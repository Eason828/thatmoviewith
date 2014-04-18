//
//  TMWCustomAnimations.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/17/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWCustomAnimations.h"

@implementation TMWCustomAnimations

+ (CABasicAnimation *)ringBorderWidthAnimation {
    
    CABasicAnimation *theAnimation;

    theAnimation=[CABasicAnimation animationWithKeyPath:@"borderWidth"];
    theAnimation.duration=1.0;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.5];
    theAnimation.toValue=[NSNumber numberWithFloat:4.0];

    return theAnimation;
}

+ (CABasicAnimation *)actorOpacityAnimation {
    
    CABasicAnimation *theAnimation;

    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=1.0;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:0.5];
    theAnimation.toValue=[NSNumber numberWithFloat:1.0];

    return theAnimation;
}

+ (CABasicAnimation *)buttonOpacityAnimation {
        
    CABasicAnimation *theAnimation;
    
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=2.0;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:0.3];
    theAnimation.toValue=[NSNumber numberWithFloat:1.0];

    return theAnimation;
}

@end
