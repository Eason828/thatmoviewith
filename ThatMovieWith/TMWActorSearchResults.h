//
//  TMWActorSearchResults.h
//  ThatMovieWith
//
//  Created by johnrhickey on 4/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMWActorSearchResults : NSObject

@property(nonatomic, copy, readonly) NSArray *results;
@property(nonatomic, copy, readonly) NSArray *names;
@property(nonatomic, copy, readonly) NSArray *lowResImageEndingURLs;

- (instancetype)initActorSearchResultsWithResults:(NSArray *)results;

@end
