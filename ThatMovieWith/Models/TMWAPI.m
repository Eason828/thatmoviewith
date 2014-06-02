//
//  TMWAPI.m
//  ThatMovieWith
//
//  Created by johnrhickey on 6/2/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWAPI.h"

@implementation TMWAPI

NSArray *APIKeyArray;

// Singleton for accessing the same instance in multiple view controllers
- (id)init
{
    self = [super init];
    if (self) {
        NSString *APIKeyPath = [[NSBundle mainBundle] pathForResource:@"TMDB_API_KEY" ofType:@""];
        
        NSString *APIKeyValueDirty = [NSString stringWithContentsOfFile:APIKeyPath
                                                               encoding:NSUTF8StringEncoding
                                                                  error:NULL];
        
        // Strip whitespace to clean the API key stdin
        NSString *APIKeyValues = [APIKeyValueDirty stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        APIKeyArray = [APIKeyValues componentsSeparatedByString:@"\n"];
    }
    return self;
}

- (NSString *)IMDBKey
{
    return APIKeyArray[0];
}

@end
