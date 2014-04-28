//
//  TMWMoviesTableViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/27/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>
#import <SVWebViewController.h>

#import "TMWActorContainer.h"
#import "TMWMoviesTableViewController.h"

@interface TMWMoviesTableViewController ()

@end

@implementation TMWMoviesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Movies";
    }
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
}

- (void)refresh
{
    int count = [[TMWActorContainer actorContainer].allActorObjects count];
    __block int i = 0;
    for (TMWActor *actor in [TMWActorContainer actorContainer].allActorObjects) {
        
        __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
        
        [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbPersonCredits withParameters:@{@"id":actor.IDNumber} andResponseBlock:^(id response, NSError *error) {
            
            if (!error) {
                actor.movies = [[NSArray alloc] initWithArray:response[@"cast"]];
                i++;
                if (i == count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }
            else {
                [errorAlertView show];
            }
        }];
    }
    
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewMethods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[TMWActorContainer actorContainer].sameMoviesNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"MoviesTable";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    if ([[TMWActorContainer actorContainer].sameMoviesNames objectAtIndex:indexPath.row] != nil) {
        cell.textLabel.text = [[TMWActorContainer actorContainer].sameMoviesNames objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Get the information about the selected movie
    [self refreshMovieResponseWithJLTMDBcall:kJLTMDbMovie
                              withParameters:@{@"id":[[TMWActorContainer actorContainer].sameMoviesIDs objectAtIndex:indexPath.row]}];
    
}

// Gets the movies each actor has been in, along with the urls
- (void) refreshMovieResponseWithJLTMDBcall:(NSString *)JLTMDBCall withParameters:(NSDictionary *)parameters
{
    
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[JLTMDbClient sharedAPIInstance] GET:JLTMDBCall withParameters:parameters andResponseBlock:^(id response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        
        if (!error) {
            NSDictionary *movieInfo = [[NSDictionary alloc] initWithDictionary:response];
            
            // If possible, open the movie in the IMDB app
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"imdb:///"]])
            {
                //NSString *info= [TMWActorModel actorModel].movieInfo[];
                NSString *imdbURL = [@"imdb:///title/" stringByAppendingString:movieInfo[@"imdb_id"]];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:imdbURL]];
            }
            // If not, open in the SVWebViewController
            else
            {
                NSString *webURL = [@"http://imdb.com/title/" stringByAppendingString:movieInfo[@"imdb_id"]];
                NSLog(@"%@", webURL);
                SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:webURL];
                webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
                [self presentViewController:webViewController animated:YES completion:NULL];
            }
            
        }
        else {
            [errorAlertView show];
        }
    }];
}

@end
