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
#import "TMWRootViewController.h"

//@interface TMWAppDelegate () <UIView>
//
//@property (nonatomic, strong) TMWRootViewController *rootView;
//
//@end

@implementation TMWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    TMWRootViewController *rootViewController = [[TMWRootViewController alloc] init];
    self.window.rootViewController = rootViewController;
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    NSString* api_key = [[NSBundle mainBundle] pathForResource:@"TMDB_API_KEY" ofType:@""];
    NSLog(@"%@", api_key);
    //[[JLTMDbClient sharedAPIInstance] setAPIKey:api_key];
    [[JLTMDbClient sharedAPIInstance] setAPIKey:@"7c260fe35bdd98cd551919a4edd5dc59"];

    
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
