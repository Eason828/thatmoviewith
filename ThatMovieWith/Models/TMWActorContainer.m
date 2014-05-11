//
//  TMWAllActors.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWActorContainer.h"

@implementation TMWActorContainer

NSMutableArray *mutableActorContainer;

static TMWActorContainer *actorContainer;

// Singleton for accessing the same instance in multiple view controllers
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        actorContainer = [[TMWActorContainer alloc] init];
    }
}

+ (TMWActorContainer *)actorContainer
{
    [self initialize];
    return actorContainer;
}

- (void)removeActorObject:(TMWActor *)actorObject
{
    if (mutableActorContainer) {
        [mutableActorContainer removeObject:actorObject];
    }
    
}

- (void)addActorObject:(TMWActor *)actorObject
{
    if (!mutableActorContainer) {
        mutableActorContainer = [[NSMutableArray alloc] init];
    }
    [mutableActorContainer addObject:actorObject];
}

- (void)removeAllActorObjects
{
    if (mutableActorContainer) {
        [mutableActorContainer removeAllObjects];
    }
}

# pragma mark Getter Methods

- (NSArray *)allActorObjects
{
    return [NSArray arrayWithArray:mutableActorContainer];
}

- (NSArray *)sameMoviesNames
{
    TMWActor *firstActor = mutableActorContainer[0];
    NSMutableArray *sameMoviesArray = [[NSMutableArray alloc] init];
    
    NSArray *IDArray = [firstActor.movies valueForKey:@"id"];
    
    // Get the movie title for all movies in sameMovieIDs
    for (id sameMovieID in self.sameMoviesIDs) {
        if ([IDArray containsObject:sameMovieID]) {
            [sameMoviesArray addObject:[firstActor.movies[[IDArray indexOfObject:sameMovieID]] valueForKey:@"original_title"]];
        }
    }
    return sameMoviesArray;
}

- (NSArray *)sameMoviesIDs
{
    NSMutableArray *mutableActorsMovies = [[NSMutableArray alloc] init];
    for (TMWActor *actor in mutableActorContainer) {
        if (actor.movies) {
            [mutableActorsMovies addObject:actor.movies];
    
        }
    }
    
    NSMutableOrderedSet *intersection = [[NSMutableOrderedSet alloc] init];
    for (NSArray *individualActorMovies in [mutableActorsMovies valueForKey:@"id"]) {
        
        if ([intersection count] != 0) {
            [intersection intersectSet:[NSSet setWithArray:individualActorMovies]];
        }
        else {
            [intersection addObjectsFromArray:individualActorMovies];
        }
    }
    return [[intersection set] allObjects];
    
}

- (NSArray *)sameMoviesPosterUrlEndings
{
    TMWActor *firstActor = mutableActorContainer[0];
    NSMutableArray *samePosterArray = [[NSMutableArray alloc] init];
    
    NSArray *IDArray = [firstActor.movies valueForKey:@"id"];
    
    // Get the poster path for all movies in sameMovieIDs
    for (id sameMovieID in self.sameMoviesIDs) {
        if ([IDArray containsObject:sameMovieID]) {
            [samePosterArray addObject:[firstActor.movies[[IDArray indexOfObject:sameMovieID]] valueForKey:@"poster_path"]];
        }
    }

    return samePosterArray;
}

@end
