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
#import "TMWActorModel.h"

@interface TMWMoviesViewController ()

@property (strong, nonatomic) IBOutlet UITableView *moviesTableView;

@end

@implementation TMWMoviesViewController

NSArray *tableData;
NSArray *sameMovies;
NSArray *movieResponseWithJLTMDBcall;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Movies";
    }
    return self;
}

- (void)viewDidLoad {
    NSLog(@"view loaded");
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"appeared");
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
//    UINavigationItem *navItem = self.navigationItem;
//    navItem.title = @"Movies";
    
    sameMovies = [TMWActorModel actorModel].chosenActorsSameMoviesNames;
    
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark UITableViewMethods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sameMovies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"MoviesTable";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [sameMovies objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Get the information about the selected movie
    [self refreshMovieResponseWithJLTMDBcall:kJLTMDbMovie
                              withParameters:@{@"id":[[TMWActorModel actorModel].chosenActorsSameMoviesIDs objectAtIndex:indexPath.row]}];
    
}


- (void) refreshMovieResponseWithJLTMDBcall:(NSString *)JLTMDBCall withParameters:(NSDictionary *)parameters
{
    
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[JLTMDbClient sharedAPIInstance] GET:JLTMDBCall withParameters:parameters andResponseBlock:^(id response, NSError *error) {
        
        if (!error) {
            [TMWActorModel actorModel].movieInfo = response;
            
            // If possible, open the movie in the IMDB app
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"imdb:///"]])
            {
                //NSString *info= [TMWActorModel actorModel].movieInfo[];
                NSString *imdbURL = [@"imdb:///title/" stringByAppendingString:[TMWActorModel actorModel].movieInfo[@"imdb_id"]];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:imdbURL]];
            }
            // If not, open in the SVWebViewController
            else
            {
            NSString *webURL = [@"http://imdb.com/title/" stringByAppendingString:[TMWActorModel actorModel].movieInfo[@"imdb_id"]];
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
