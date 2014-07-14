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
        DDLogInfo(@"Removed actor: %@ (ID %@)", actorObject.name, actorObject.IDNumber);
    }
}

- (void)addActorObject:(TMWActor *)actorObject
{
    if (!mutableActorContainer) {
        mutableActorContainer = [[NSMutableArray alloc] init];
    }
    [mutableActorContainer addObject:actorObject];
    DDLogInfo(@"Added actor: %@ (ID %@)", actorObject.name, actorObject.IDNumber);
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

- (NSArray *)actorNames
{
    NSMutableArray *actorNamesMutableArray = [[NSMutableArray alloc] init];
    for (TMWActor *actor in mutableActorContainer) {
        if (actor.name) {
            [actorNamesMutableArray addObject:actor.name];
        }
    }
    return actorNamesMutableArray;
}

- (NSArray *)sameMovies
{
    NSMutableArray *actorsMoviesMutableArray = [[NSMutableArray alloc] init];
    for (TMWActor *actor in mutableActorContainer) {
        if (actor.movies) {
            [actorsMoviesMutableArray addObject:actor.movies];
        }
    }
    
    // Get a intersection containing the IDs of the same movies
    NSMutableOrderedSet *intersection = [[NSMutableOrderedSet alloc] init];
    for (NSArray *individualActorMovies in [actorsMoviesMutableArray valueForKey:@"id"]) {
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
    NSMutableArray *sameMoviesIDsMutableArray = [[NSMutableArray alloc] init];
    
    NSArray *IDArray = [firstActor.movies valueForKey:@"id"];
    
    // Get the movie id for all movies in sameMovieIDs
    for (id sameMovieID in [self.sameMovies valueForKey:@"id"]) {
        if ([IDArray containsObject:sameMovieID]) {
            [sameMoviesIDsMutableArray addObject:[firstActor.movies[[IDArray indexOfObject:sameMovieID]] valueForKey:@"id"]];
        }
    }
    return sameMoviesIDsMutableArray;
}

- (NSArray *)sameMoviesNames
{
    TMWActor *firstActor = mutableActorContainer[0];
    NSMutableArray *sameMoviesNamesMutableArray = [[NSMutableArray alloc] init];
    
    NSArray *IDArray = [firstActor.movies valueForKey:@"id"];
    
    // Get the movie title for all movies in sameMovieIDs
    for (id sameMovieID in [self.sameMovies valueForKey:@"id"]) {
        if ([IDArray containsObject:sameMovieID]) {
            [sameMoviesNamesMutableArray addObject:[firstActor.movies[[IDArray indexOfObject:sameMovieID]] valueForKey:@"original_title"]];
        }
    }
    return sameMoviesNamesMutableArray;
}

- (NSArray *)sameMoviesPosterUrlEndings
{
    TMWActor *firstActor = mutableActorContainer[0];
    NSMutableArray *samePosterMutableArray = [[NSMutableArray alloc] init];
    
    NSArray *IDArray = [firstActor.movies valueForKey:@"id"];
    
    // Get the poster path for all movies in sameMovieIDs
    for (id sameMovieID in [self.sameMovies valueForKey:@"id"]) {
        if ([IDArray containsObject:sameMovieID]) {
            [samePosterMutableArray addObject:[firstActor.movies[[IDArray indexOfObject:sameMovieID]] valueForKey:@"poster_path"]];
        }
    }

    return samePosterMutableArray;
}

- (NSArray *)sameMoviesReleaseYears
{
    NSMutableArray *sameMoviesReleaseDatesArray = [[NSMutableArray alloc] init];
    
    TMWActor *firstActor = mutableActorContainer[0];
    
    NSArray *IDArray = [firstActor.movies valueForKey:@"id"];
    
    // Get the movie title for all movies in sameMovieIDs
    for (id sameMovieID in [self.sameMovies valueForKey:@"id"]) {
        if ([IDArray containsObject:sameMovieID]) {
            if ([firstActor.movies[[IDArray indexOfObject:sameMovieID]] valueForKey:@"release_date"] == (id)[NSNull null]) {
                NSString* unknownString = @"TBA";
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
