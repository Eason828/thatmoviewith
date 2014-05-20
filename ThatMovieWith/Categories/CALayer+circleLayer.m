//
//  CALayer+circleLayer.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/17/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "CALayer+circleLayer.h"

@implementation CALayer (circleLayer)

+ (void)circleLayer:(CALayer *)layer
{
	    layer.cornerRadius = layer.frame.size.height/2;
        layer.masksToBounds = YES;
        layer.borderWidth = 0;
}

+ (void)dropShadowLayer:(CALayer *)layer
{
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOffset = CGSizeMake(5, 5);
    layer.shadowRadius = 3.0;
    layer.shadowOpacity = 0.5;
}


@end
