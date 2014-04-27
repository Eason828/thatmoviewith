//
//  TMWActor.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//
#import <JLTMDbClient.h>

#import "TMWActor.h"

@interface TMWActor()

@property(nonatomic, copy, readwrite) NSNumber *IDNumber;
@property(nonatomic, copy, readwrite) NSString *name;
@property(nonatomic, copy, readwrite) NSArray *movies;
@property(nonatomic, copy, readwrite) NSString *hiResImageURLEnding;

@end

@implementation TMWActor

- (instancetype)initWithActor:(NSDictionary *)actor
{
    if (self) {
        _name = actor[@"name"];
        _IDNumber = actor[@"id"];
        [self fetchActorMoviesWithID:_IDNumber];
        if ([actor[@"profile_path"] isKindOfClass:[NSString class]])
        {
            _hiResImageURLEnding = actor[@"profile_path"];
        }
    }
    return self;
}

# pragma mark Getter Methods

- (void)fetchActorMoviesWithID:(NSNumber *)actorFetchID
{
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbPersonCredits withParameters:@{@"id":actorFetchID} andResponseBlock:^(id response, NSError *error) {
        
        if (!error) {
            _movies = [[NSArray alloc] initWithArray:response[@"cast"]];
        }
        else {
            [errorAlertView show];
        }
    }];
    
}

@end
