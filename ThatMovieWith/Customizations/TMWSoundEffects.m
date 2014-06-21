//
//  TMWPlaySound.m
//  ThatMovieWith
//
//  Created by johnrhickey on 6/21/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWSoundEffects.h"

#import <AudioToolbox/AudioServices.h>

@implementation TMWSoundEffects

static TMWSoundEffects *soundEffects;

// Singleton for accessing the same instance in multiple view controllers
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
    }
}

+ (TMWSoundEffects *)soundEffects
{
    [self initialize];
    soundEffects = [[TMWSoundEffects alloc] init];
    return soundEffects;
}

- (void)playSound:(NSString *)sound
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SoundsEnabled"] == YES) {
        // Play sound
        NSDictionary *mainDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Sounds" ofType:@"plist"]];
        NSString *path  = [[NSBundle mainBundle] pathForResource:mainDictionary[sound] ofType:@"m4a"];
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        SystemSoundID audioEffect;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
    }
}

@end
