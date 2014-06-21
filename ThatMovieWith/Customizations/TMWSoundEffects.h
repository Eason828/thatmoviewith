//
//  TMWPlaySound.h
//  ThatMovieWith
//
//  Created by johnrhickey on 6/21/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMWSoundEffects : NSObject

+ (TMWSoundEffects *)soundEffects;
- (void)playSound:(NSString *)sound;

@end
