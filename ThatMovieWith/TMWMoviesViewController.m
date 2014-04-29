//
//  TMWMoviesViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/19/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//
#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>
#import <SVWebViewController.h>

#import "TMWMoviesViewController.h"
#import "TMWActorContainer.h"

@interface TMWMoviesViewController ()

@property (strong, nonatomic) IBOutlet UITableView *moviesTableView;
@property (strong, nonatomic) IBOutlet UIView *noResultsView;
@property (strong, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UINavigationItem *navItem;

@end

@implementation TMWMoviesViewController

NSInteger tableViewRows;
NSArray *movieResponseWithJLTMDBcall;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navItem = self.navigationItem;
    self.navItem.title = @"Movies";
    self.navigationController.navigationBar.translucent = NO;
    
    // Add pull to refresh to the table view
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.moviesTableView addSubview:self.refreshControl];
    [self.view addSubview:self.moviesTableView];
    // Set the table to be empty by default
    tableViewRows = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    // Refresh the table view
    [self refresh];
}

- (void)refresh
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Fetch the movie data for all actors in the container
    __block int i = 1;
    for (TMWActor *actor in [TMWActorContainer actorContainer].allActorObjects) {
        
        __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
        
        [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbPersonCredits withParameters:@{@"id":actor.IDNumber} andResponseBlock:^(id response, NSError *error) {
            
            if (!error) {
                actor.movies = [[NSArray alloc] initWithArray:response[@"cast"]];
                if (i == [[TMWActorContainer actorContainer].allActorObjects count]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        tableViewRows = [[TMWActorContainer actorContainer].sameMoviesNames count];
                        if([[TMWActorContainer actorContainer].sameMoviesNames count] == 0 ){
                            self.moviesTableView.hidden = YES;
                            self.noResultsView.hidden = NO;
                        } else {
                            self.moviesTableView.hidden = NO;
                            self.noResultsView.hidden = YES;
                        }
                        [self.moviesTableView reloadData];
                    });
                }
                i++;
            }
            else {
                [errorAlertView show];
            }
        }];
    }
    
    [self.refreshControl endRefreshing];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark UITableViewMethods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableViewRows;
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
