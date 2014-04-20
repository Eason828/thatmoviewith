//
//  TMWMoviesViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/19/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//
#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>

#import "TMWMoviesViewController.h"
#import "TMWActorViewController.h"
#import "TMWActorModel.h"

@interface TMWMoviesViewController ()

@property (strong, nonatomic) TMWActorModel *actor;

@end

@implementation TMWMoviesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.actor = [[TMWActorModel alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

//
//- (void) refreshActorResponseWithJLTMDBcall:(NSString *)JLTMDBCall withParameters:(NSDictionary *) parameters
//{
//    
//    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
//    
//    [[JLTMDbClient sharedAPIInstance] GET:JLTMDBCall withParameters:parameters andResponseBlock:^(id response, NSError *error) {
//        
//        if (!error) {
//            self.actor.actorsArray = response[@"results"];
//            //[[self.searchBarController searchResultsTableView] reloadData];
//        }
//        else {
//            [errorAlertView show];
//        }
//    }];
//}


@end
