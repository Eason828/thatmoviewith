//
//  TMWAppDelegate.h
//  ThatMovieWith
//
//  Created by johnrhickey on 4/15/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DDFileLogger.h>

@interface TMWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) DDFileLogger *fileLogger;
- (NSString *) getLogFilesContentWithMaxSize:(NSInteger)maxSize;

@end
