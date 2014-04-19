//
//  TMWActorModel.h
//  ThatMovieWith
//
//  Created by johnrhickey on 4/18/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMWActorModel : NSObject

@property (nonatomic, strong) NSArray *actorSearchResults;
@property (nonatomic, strong, readonly) NSArray *actorSearchResultNames;
@property (nonatomic, strong, readonly) NSArray *actorSearchResultImages;

@property (nonatomic, strong, readonly) NSArray *chosenActors;
@property (nonatomic, strong, readonly) NSArray *chosenActorsIDs;
@property (nonatomic, strong) NSArray *chosenActorMovies;
@property (nonatomic, strong, readonly) NSArray *chosenActorsSameMovies;

- (void)addChosenActor:(NSDictionary *)actor;
- (void)removeChosenActor:(NSDictionary *)actor;

@end
