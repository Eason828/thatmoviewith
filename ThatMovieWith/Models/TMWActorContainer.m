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

- (NSArray *)sameMovies
{
    NSMutableArray *mutableActorsMovies = [[NSMutableArray alloc] init];
    for (TMWActor *actor in mutableActorContainer) {
        if (actor.movies) {
            [mutableActorsMovies addObject:actor.movies];
        }
    }
    
    // Get a intersection containing the IDs of the same movies
    NSMutableOrderedSet *intersection = [[NSMutableOrderedSet alloc] init];
    for (NSArray *individualActorMovies in [mutableActorsMovies valueForKey:@"id"]) {
        if ([intersection count] != 0) {
            [intersection intersectSet:[NSSet setWithArray:individualActorMovies]];
        }
        else {
            [intersection addObjectsFromArray:individualActorMovies];
        }
    }
    NSArray *sameIDs = [[intersection set] allObjects];
    
    // Create an array movies objects from those IDs
    TMWActor *firstActor = mutableActorContainer[0];
    NSMutableArray *sameMoviesArray = [[NSMutableArray alloc] init];
    NSArray *IDArray = [firstActor.movies valueForKey:@"id"];
    
    for (id sameMovieID in sameIDs) {
        if ([IDArray containsObject:sameMovieID]) {
            [sameMoviesArray addObject:firstActor.movies[[IDArray indexOfObject:sameMovieID]]];
        }
    }
    
    // Sort the movies by release date
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"release_date"
                                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    NSArray *sortedMoviesArray = [sameMoviesArray sortedArrayUsingDescriptors:sortDescriptors];
    
    // Put the movies with "null" release dates first, because they're likely to
    // be movies that aren't out yet.
    NSMutableArray *nullFirstArray = [[NSMutableArray alloc] initWithArray:sortedMoviesArray];
    for (id movie in sortedMoviesArray) {
        if ([movie valueForKey:@"release_date"] == (id)[NSNull null]) {
            [nullFirstArray removeObject:movie];
            [nullFirstArray insertObject:movie atIndex:0];
        }
    }
    return nullFirstArray;
}

- (NSArray *)sameMoviesIDs
{
    TMWActor *firstActor = mutableActorContainer[0];
    NSMutableArray *sameMoviesIDsArray = [[NSMutableArray alloc] init];
    
    NSArray *IDArray = [firstActor.movies valueForKey:@"id"];
    
    // Get the movie id for all movies in sameMovieIDs
    for (id sameMovieID in [self.sameMovies valueForKey:@"id"]) {
        if ([IDArray containsObject:sameMovieID]) {
            [sameMoviesIDsArray addObject:[firstActor.movies[[IDArray indexOfObject:sameMovieID]] valueForKey:@"id"]];
        }
    }
    return sameMoviesIDsArray;
}

- (NSArray *)sameMoviesNames
{
    TMWActor *firstActor = mutableActorContainer[0];
    NSMutableArray *sameMoviesNamesArray = [[NSMutableArray alloc] init];
    
    NSArray *IDArray = [firstActor.movies valueForKey:@"id"];
    
    // Get the movie title for all movies in sameMovieIDs
    for (id sameMovieID in [self.sameMovies valueForKey:@"id"]) {
        if ([IDArray containsObject:sameMovieID]) {
            [sameMoviesNamesArray addObject:[firstActor.movies[[IDArray indexOfObject:sameMovieID]] valueForKey:@"original_title"]];
        }
    }
    return sameMoviesNamesArray;
}

- (NSArray *)sameMoviesPosterUrlEndings
{
    TMWActor *firstActor = mutableActorContainer[0];
    NSMutableArray *samePosterArray = [[NSMutableArray alloc] init];
    
    NSArray *IDArray = [firstActor.movies valueForKey:@"id"];
    
    // Get the poster path for all movies in sameMovieIDs
    for (id sameMovieID in [self.sameMovies valueForKey:@"id"]) {
        if ([IDArray containsObject:sameMovieID]) {
            [samePosterArray addObject:[firstActor.movies[[IDArray indexOfObject:sameMovieID]] valueForKey:@"poster_path"]];
        }
    }

    return samePosterArray;
}

- (NSArray *)sameMoviesReleaseDates
{
    TMWActor *firstActor = mutableActorContainer[0];
    NSMutableArray *sameMoviesReleaseDatesArray = [[NSMutableArray alloc] init];
    
    NSArray *IDArray = [firstActor.movies valueForKey:@"id"];
    
    // Get the movie title for all movies in sameMovieIDs
    for (id sameMovieID in [self.sameMovies valueForKey:@"id"]) {
        if ([IDArray containsObject:sameMovieID]) {
            if ([firstActor.movies[[IDArray indexOfObject:sameMovieID]] valueForKey:@"release_date"] == (id)[NSNull null]) {
                NSString* unknownString = @"N/A";
                [sameMoviesReleaseDatesArray addObject:unknownString];
            
            }
            else {
                NSString *releaseDateString = [firstActor.movies[[IDArray indexOfObject:sameMovieID]] valueForKey:@"release_date"];
                [sameMoviesReleaseDatesArray addObject:[releaseDateString substringToIndex:4]];
            }
        }
    }
    return sameMoviesReleaseDatesArray;
}

@end
