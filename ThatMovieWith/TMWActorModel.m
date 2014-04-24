//
//  TMWActorModel.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/18/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//
#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>

#import "TMWActorModel.h"
#import "UIImage+DrawInitialsOnImage.h"

@implementation TMWActorModel

NSMutableArray *mutableActors;
NSMutableArray *mutableActorsMovies;

static TMWActorModel *actorModel;

// Singleton for accessing the same instance in multiple view controllers
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        actorModel = [[TMWActorModel alloc] init];
    }
}

+(TMWActorModel *)actorModel
{
    [self initialize];
    return actorModel;
}

#pragma mark Getter Methods

- (NSArray *)actorSearchResultNames {
    // Create an array of the names for the UITableView
    NSMutableArray *mutableNamesArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.actorSearchResults) {
        [mutableNamesArray addObject:dict[@"name"]];
    }
    return mutableNamesArray;
}

// Get the full size actor image
- (NSArray *)actorSearchResultImagesLowRes {
    NSMutableArray *mutableImagesArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.actorSearchResults)
    {
        if (dict[@"profile_path"] != (id)[NSNull null])
        {
            [mutableImagesArray addObject:dict[@"profile_path"]];
        }
        else
        {
            UIImage *defaultImage = [UIImage imageByDrawingInitialsOnImage:[UIImage imageNamed:@"InitialsBackgroundLowRes.png"] withInitials:dict[@"name"] withFontSize:16];
            [mutableImagesArray addObject:defaultImage];
        }
    }
    return mutableImagesArray;
}

- (NSArray *)actorSearchResultImagesHiRes {
    NSMutableArray *mutableImagesArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.actorSearchResults)
    {
        if (dict[@"profile_path"] != (id)[NSNull null])
        {
            [mutableImagesArray addObject:dict[@"profile_path"]];
        }
        else
        {
            UIImage *defaultImage = [UIImage imageByDrawingInitialsOnImage:[UIImage imageNamed:@"InitialsBackgroundHiRes.png"] withInitials:dict[@"name"] withFontSize:48];
            [mutableImagesArray addObject:defaultImage];
        }
    }
    return mutableImagesArray;
}

- (NSArray *)chosenActors
{
    NSLog(@"Chosen actors: %@", mutableActors);
    return mutableActors;
}

- (NSArray *)chosenActorsIDs
{
    NSMutableArray *mutableIDs = [NSMutableArray array];
    for (NSDictionary *actor in self.chosenActors) {
        [mutableIDs addObject:actor[@"id"]];
    }
    return [NSArray arrayWithArray:mutableIDs];
}

- (NSArray *)chosenActorsSameMoviesNames
{
    NSMutableOrderedSet *intersection = [[NSMutableOrderedSet alloc] init];

    for (NSArray *individualActorMovies in [mutableActorsMovies valueForKey:@"original_title"]) {

        if (![intersection count] == 0) {
            [intersection intersectSet:[NSSet setWithArray:individualActorMovies]];
        }
        else {
            [intersection addObjectsFromArray:individualActorMovies];
        }
    }
    
    return [[intersection set] allObjects];
}

- (NSArray *)chosenActorsSameMoviesIDs
{
    NSMutableOrderedSet *intersection = [[NSMutableOrderedSet alloc] init];
    
    for (NSArray *individualActorMovies in [mutableActorsMovies valueForKey:@"id"]) {
        
        if (![intersection count] == 0) {
            [intersection intersectSet:[NSSet setWithArray:individualActorMovies]];
        }
        else {
            [intersection addObjectsFromArray:individualActorMovies];
        }
    }
    
    return [[intersection set] allObjects];
}

- (void)setActorSearchResults:(NSArray *)searchResults
{
    _actorSearchResults = [self organizeSearchResultsByImageWithArray:searchResults];
}

#pragma mark Instance Methods

- (void)addChosenActor:(NSDictionary *)actor {
    if (!mutableActors) {
        mutableActors = [[NSMutableArray alloc] init];
    }
    
    [mutableActors addObject:actor];
}

- (void)removeChosenActor:(NSDictionary *)actor
{
    if ([mutableActors containsObject:actor]) {
        [mutableActors removeObject:actor];
    }
    else {
        NSLog(@"%@ is not present in the array", actor[@"name"]);
    }
}

- (void)addActorMovies:(NSArray *)movies
{
    if (!mutableActorsMovies) {
        mutableActorsMovies = [[NSMutableArray alloc] init];
    }
    [mutableActorsMovies addObject:movies];
}

- (void)removeAllActorMovies
{
    [mutableActorsMovies removeAllObjects];
}

- (NSArray *)organizeSearchResultsByImageWithArray:(NSArray *)results
{
    NSMutableArray *mutableResults = [NSMutableArray arrayWithArray:results];
    for (NSDictionary *person in results)
    {
        if (person[@"profile_path"] == (id)[NSNull null])
        {
            [mutableResults removeObject:person];
            [mutableResults addObject:person];
        }
    }
    return [NSArray arrayWithArray:mutableResults];
}

@end
