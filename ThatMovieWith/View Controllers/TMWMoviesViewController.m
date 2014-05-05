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
#import "TMWCustomMovieCellTableViewCell.h"

#import "UIImage+DrawInitialsOnImage.h" // Actor's without images

@interface TMWMoviesViewController ()

@property (strong, nonatomic) IBOutlet UITableView *moviesTableView;
@property (strong, nonatomic) IBOutlet UIView *noResultsView;
@property (strong, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UINavigationItem *navItem;

@end

@implementation TMWMoviesViewController

static const NSUInteger TABLE_HEIGHT = 88;

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
    __block NSUInteger i = 1;
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

// Change the Height of the Cell [Default is 44]:
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return TABLE_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    TMWCustomMovieCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TMWCustomMovieCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:CellIdentifier];
        tableView.showsVerticalScrollIndicator = YES;
        [cell layoutSubviews];
        
        // Set the line separator left offset to start after the image
        [tableView setSeparatorInset:UIEdgeInsetsMake(0, IMAGE_SIZE+IMAGE_TEXT_OFFSET, 0, 0)];
    }
    
    if ([[TMWActorContainer actorContainer].sameMoviesNames objectAtIndex:indexPath.row] != nil) {
        cell.textLabel.text = [[TMWActorContainer actorContainer].sameMoviesNames objectAtIndex:indexPath.row];
    }
    
    // grab bound for contentView
    CGRect contentViewBound = cell.imageView.bounds;
    
    // If NSString, fetch the image, else use the generated UIImage
    if ([[[TMWActorContainer actorContainer].sameMoviesPosterUrlEndings objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        
        NSString *urlstring = [[[TMWActorContainer actorContainer].imagesBaseURLString stringByReplacingOccurrencesOfString:[TMWActorContainer actorContainer].backdropSizes[1] withString:[TMWActorContainer actorContainer].backdropSizes[3]] stringByAppendingString:[[TMWActorContainer actorContainer].sameMoviesPosterUrlEndings objectAtIndex:indexPath.row]];
        
        // Show the network activity icon
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        
        // Get the image from the URL and set it
        [cell.imageView setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:[UIImage imageNamed:@"Clear.png"]];
        CGRect imageViewFrame = cell.imageView.frame;
        // change x position
        imageViewFrame.origin.y = contentViewBound.size.height - imageViewFrame.size.height;
        // assign the new frame
        cell.imageView.frame = imageViewFrame;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        // Hide the network activity icon
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    else {
        UIImage *defaultImage = [UIImage imageByDrawingInitialsOnImage:[UIImage imageNamed:@"MoviesBackgroundHiRes.png"] withInitials:[[TMWActorContainer actorContainer].sameMoviesNames objectAtIndex:indexPath.row] withFontSize:120];
        [cell.imageView setImage:defaultImage];
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
            
            NSString *webURL = [@"http://imdb.com/title/" stringByAppendingString:movieInfo[@"imdb_id"]];
            NSLog(@"%@", webURL);
                SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:webURL];
                webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
                [self presentViewController:webViewController animated:YES completion:NULL];
            
        }
        else {
            [errorAlertView show];
        }
    }];
}

@end
