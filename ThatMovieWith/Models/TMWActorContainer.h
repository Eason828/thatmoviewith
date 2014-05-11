//
//  TMWAllActors.h
//  ThatMovieWith
//
//  Created by johnrhickey on 4/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWActor.h"

@interface TMWActorContainer : TMWActor

@property(nonatomic, copy, readonly) NSArray *allActorObjects;
@property(nonatomic, copy, readonly) NSArray *sameMovies;
@property(nonatomic, copy, readonly) NSArray *sameMoviesNames;
@property(nonatomic, copy, readonly) NSArray *sameMoviesPosterUrlEndings;
@property(nonatomic, copy, readonly) NSArray *sameMoviesIDs;
@property(nonatomic, copy) NSString *imagesBaseURLString;
@property(nonatomic, copy) NSArray *backdropSizes;

+ (TMWActorContainer *)actorContainer;

- (void)removeActorObject:(TMWActor *)actorObject;
- (void)addActorObject:(TMWActor *)actorObject;
- (void)removeAllActorObjects;

@end
