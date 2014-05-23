//
//  TMWActorSearchResults.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWActorSearchResults.h"
#import "UIImage+DrawOnImage.h"

@interface TMWActorSearchResults()

@property(nonatomic, copy) NSArray *results;
@property(nonatomic, copy) NSArray *names;
@property(nonatomic, copy) NSArray *lowResImageEndingURLs;

@end

@implementation TMWActorSearchResults

- (instancetype)initActorSearchResultsWithResults:(NSArray *)results
{
    if (self) {
        self.results = results;
    }
    return self;
}

# pragma mark Getter Methods

- (NSArray *)names
{
    NSMutableArray *mutableNamesArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in _results) {
        [mutableNamesArray addObject:dict[@"name"]];
    }
    return mutableNamesArray;
}

- (NSArray *)lowResImageEndingURLs
{
    NSMutableArray *mutableImagesArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in _results)
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

- (void)setResults:(NSArray *)searchResults
{
    _results = [self organizeSearchResultsByImageWithArray:searchResults];
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
