//
//  TMWActors.h
//  ThatMovieWith
//
//  Created by johnrhickey on 4/16/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMWActors : NSObject

- (NSArray *)retrieveActorDataResultsForName:(NSString *)query;
- (NSArray *)retrieveActorNameResultsForName:(NSString *)query;
- (UIImage *)retriveActorImageForProfilePath:(NSString *)profileImagePath;


@end
