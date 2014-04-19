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

@implementation TMWActorModel {
    NSMutableArray *mutableActors;
}

#pragma mark Getter Methods

- (NSArray *)actorNames {
    // Create an array of the names for the UITableView
    NSMutableArray *mutableNamesArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.actorsArray) {
        [mutableNamesArray addObject:dict[@"name"]];
    }
    return mutableNamesArray;
}

- (NSArray *)actorImages {
    NSMutableArray *mutableImagesArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.actorsArray)
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
    _chosenActors = mutableActors;
    NSLog(@"ChosenActors: %@", _chosenActors);
    return _chosenActors;
}

#pragma mark Instance Methods

- (void)addChosenActor:(NSDictionary *)actor {
    if (!mutableActors) {
        mutableActors = [[NSMutableArray alloc] init];
    }
    [mutableActors addObject:actor];
    NSLog(@"MutableActors: %@", mutableActors);
}

- (void)removeChosenActor:(NSDictionary *)actor
{
    if ([mutableActors containsObject:actor]) {
        NSLog(@"Removing actor: %@", actor[@"name"]);
        NSLog(@"%d", [mutableActors indexOfObject:actor[@"name"]]);
        [mutableActors removeObject:actor];
    } else {
        NSLog(@"%@ is not present in the array", actor[@"name"]);
    }
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
