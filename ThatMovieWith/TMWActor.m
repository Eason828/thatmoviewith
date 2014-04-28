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
@property(nonatomic, copy, readwrite) NSString *hiResImageURLEnding;

@end

@implementation TMWActor

- (instancetype)initWithActor:(NSDictionary *)actor
{
    if (self) {
        _name = actor[@"name"];
        _IDNumber = actor[@"id"];
        if ([actor[@"profile_path"] isKindOfClass:[NSString class]])
        {
            _hiResImageURLEnding = actor[@"profile_path"];
        }
    }
    return self;
}

@end
