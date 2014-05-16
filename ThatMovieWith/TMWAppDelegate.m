//
//  TMWAppDelegate.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/15/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <JLTMDbClient.h>
#import "HockeySDK.h"
#import "TMWAppDelegate.h"
#import "TMWContainerViewController.h"
#import "FBTweak.h"
#import "FBTweakInline.h"
#import "FBTweakShakeWindow.h"
#import "FBTweakViewController.h"

#import "UIColor+customColors.h"

@interface TMWAppDelegate () <FBTweakObserver, FBTweakViewControllerDelegate>
@end

@implementation TMWAppDelegate {
    FBTweak *_flipTweak; // TODO: Remove FBTweaks here
}

// TODO: Remove FBTweaks here
- (UIWindow *)window
{
    if (!_window) {
        _window = [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    return _window;
}
// TODO: Remove FBTweaks here
- (void)tweakDidChange:(FBTweak *)tweak
{
    if (tweak == _flipTweak) {
        _window.layer.sublayerTransform = CATransform3DMakeScale(1.0, [_flipTweak.currentValue boolValue] ? -1.0 : 1.0, 1.0);
    }
}
// TODO: Remove FBTweaks here
- (void)tweakViewControllerPressedDone:(FBTweakViewController *)tweakViewController
{
    [tweakViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // TODO: Remove FBTweaks here
    FBTweakAction(@"Actions", @"Scoped", @"One", ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"Scoped alert test #1." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Done", nil];
        [alert show];
    });
    
    // TODO: Remove FBTweaks here
    self.window = [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    
    TMWContainerViewController *containerController = [TMWContainerViewController new];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:containerController];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    // Hockey app needs to be the last 3rd party integration in this method
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"3930bb009663ec2c32cb9a5ca2b8a1a4"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
