//
//  TMWActor.h
//  ThatMovieWith
//
//  Created by johnrhickey on 4/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMWActor : NSObject

@property(nonatomic, copy, readonly) NSNumber *IDNumber;
@property(nonatomic, copy, readonly) NSString *name;
@property(nonatomic, copy, readonly) NSArray *movies;
@property(nonatomic, copy, readonly) NSString *hiResImageURLEnding;

- (instancetype)initWithActor:(NSDictionary *)actor;

@end
