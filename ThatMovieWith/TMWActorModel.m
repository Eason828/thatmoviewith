//
//  TMWActorModel.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/18/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWActorModel.h"
#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>

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

- (NSArray *)actorSearchResultImages {
    NSMutableArray *mutableImagesArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.actorSearchResults)
    {
        if (dict[@"profile_path"] != (id)[NSNull null])
        {
            [mutableImagesArray addObject:dict[@"profile_path"]];
        }
        else
        {
            UIImage *defaultImage = [self imageByDrawingInitialsOnImage:[UIImage imageNamed:@"InitialsBackground.png"] withInitials:dict[@"name"]];
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


#pragma mark Private Methods

- (UIImage *)imageByDrawingInitialsOnImage:(UIImage *)image withInitials:(NSString *)initials
{
    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContext(image.size);
    
    // draw original image into the context
    [image drawAtPoint:CGPointZero];
    
    // get the context for CoreGraphics
    UIGraphicsGetCurrentContext();
    
    NSArray *separatedNames = [initials componentsSeparatedByString:@" "];
    
    if ([separatedNames count] > 0) {
        NSMutableString *combinedInitials = [[NSMutableString alloc] initWithString:[separatedNames[0] substringToIndex:1]];
        if ([separatedNames count] > 1) {
            [combinedInitials appendString:[separatedNames[1] substringToIndex:1]];
        }
        
        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByWordWrapping;
        textStyle.alignment = NSTextAlignmentCenter;
        UIFont *textFont = [UIFont systemFontOfSize:16];
        
        NSDictionary *attributes = @{NSFontAttributeName: textFont};
        
        // Create the CGRect to the size of the text box
        CGSize size = [combinedInitials sizeWithAttributes:attributes];
        if (size.width < image.size.width)
        {
            CGRect textRect = CGRectMake(0,
                                         (image.size.height - size.height)/2,
                                         image.size.width,
                                         (image.size.height - size.height));
            
            [combinedInitials drawInRect:textRect withAttributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle}];
        }
    }
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // free the context
    UIGraphicsEndImageContext();
    
    return retImage;
}

@end
