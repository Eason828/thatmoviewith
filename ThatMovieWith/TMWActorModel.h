//
//  TMWActorModel.h
//  ThatMovieWith
//
//  Created by johnrhickey on 4/18/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMWActorModel : NSObject

@property (nonatomic, strong) NSArray *actorsArray;
@property (nonatomic, strong, readonly) NSArray *actorNames;
@property (nonatomic, strong, readonly) NSArray *actorImages;

@property (nonatomic, strong) NSArray *chosenActors;
@property (nonatomic, strong, readonly) NSArray *actorMovies;
@property (nonatomic, strong, readonly) NSArray *sameMovies;

- (void)addChosenActor:(NSDictionary *)actor;
- (void)removeChosenActor:(NSDictionary *)actor;



@end
