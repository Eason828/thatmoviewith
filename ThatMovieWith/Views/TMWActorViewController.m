//
//  TMWActorViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 5/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//
#import <AudioToolbox/AudioServices.h>

#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>
#import <FBShimmeringView.h>
#import <CWStatusBarNotification.h>
#import "SVProgressHUD.h"


#import "TMWActorViewController.h"
#import "TMWActor.h"
#import "TMWSoundEffects.h"
#import "TMWActorContainer.h"
#import "TMWContainerViewController.h"
#import "TMWActorSearchResults.h"
#import "TMWMoviesCollectionViewController.h"
#import "TMWCustomActorCellTableViewCell.h"
#import "TMWAPI.h"
#import "TMWAppDelegate.h"

#import "UIImage+ImageEffects.h"
#import "UIColor+customColors.h"
#import "UIImage+DrawOnImage.h"

@interface TMWActorViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;
@property (strong, nonatomic) IBOutlet UIButton *thatMovieWithButton;
@property (strong, nonatomic) IBOutlet UIButton *andButton;

@property (strong, nonatomic) UIButton *firstActorButton;
@property (strong, nonatomic) UIButton *secondActorButton;
@property (strong, nonatomic) UILabel *firstActorLabel;
@property (strong, nonatomic) UILabel *secondActorLabel;
@property (strong, nonatomic) UIImageView *blurImageView;
@property (strong, nonatomic) UIImageView *curtainView;
@property (strong, nonatomic) UIScrollView *firstActorScrollView;
@property (strong, nonatomic) UIScrollView *secondActorScrollView;
@property (strong, nonatomic) UIView *firstActorActionView;
@property (strong, nonatomic) UIView *secondActorActionView;
@property (strong, nonatomic) UILabel *firstActorActionLabel;
@property (strong, nonatomic) UILabel *secondActorActionLabel;
@property (strong, nonatomic) UILabel *firstActorDeleteLabel;
@property (strong, nonatomic) UILabel *secondActorDeleteLabel;
@property (strong, nonatomic) UIView *statusBarView;
@property (strong, nonatomic) FBShimmeringView *thatMovieShimmeringView;
@property (strong, nonatomic) FBShimmeringView *andShimmeringView;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;

@end

@implementation TMWActorViewController

static const NSUInteger TABLE_HEIGHT = 66;
static const NSUInteger ACTOR_FONT_SIZE = 42;
NSUInteger scrollOffset;

NSString *moviesSlideString = @"Show\nMovies";
NSString *deleteSlideString = @"Remove\nActor";

TMWActorSearchResults *searchResults;
TMWActorSearchResults *newSearchResults;
TMWActor *actor1;
TMWActor *actor2;
int tappedActor;
bool hasSearched;
bool doneLoadingActorImage;
bool pastSoundThreshold;
float frameX;
float frameY;
float frameW;
float frameH;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Actors";
        
        TMWAPI *api = [TMWAPI new];
        hasSearched = NO;
        
        [[JLTMDbClient sharedAPIInstance] setAPIKey:api.IMDBKey];
    }
    return self;
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // Layout only on the first load
    if (!hasSearched) {
        scrollOffset = 105;
        _curtainView.frame = self.view.frame;
        _statusBarView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 20);
        
        frameX = self.view.frame.origin.x;
        frameY = self.view.frame.origin.y;
        frameW = self.view.frame.size.width;
        frameH = self.view.frame.size.height;
        
        if (fmodf(self.view.frame.size.height, 2)) {
            _firstActorScrollView.frame = CGRectMake(self.view.frame.origin.x - scrollOffset, frameY - 1, self.view.frame.size.width + scrollOffset, frameH/2 + 1);
            _firstActorScrollView.contentSize = CGRectMake(self.view.frame.origin.x, frameY, self.view.frame.size.width + (scrollOffset * 2.0), floor(frameH/2) + 1).size;
            _firstActorButton.frame = CGRectMake(self.view.frame.origin.x + scrollOffset, self.view.frame.origin.y - 1, self.view.frame.size.width, floor(frameH/2) + 2);
            _firstActorActionView.frame = CGRectMake(frameX, frameY, frameW + scrollOffset, floor(frameH/2) + 1);
            
            _secondActorScrollView.frame = CGRectMake(self.view.frame.origin.x - scrollOffset, frameY + floor(frameH/2) - 1, self.view.frame.size.width + scrollOffset, floor(frameH/2) + 2);
            _secondActorScrollView.contentSize = CGRectMake(self.view.frame.origin.x, frameY - 1, self.view.frame.size.width + (scrollOffset * 2.0), floor(frameH/2) + 2).size;
            _secondActorButton.frame = CGRectMake(self.view.frame.origin.x + scrollOffset, frameY - 1, self.view.frame.size.width, floor(frameH/2) + 4);
        }
        else {
            _firstActorScrollView.frame = CGRectMake(self.view.frame.origin.x - scrollOffset, frameY, self.view.frame.size.width + scrollOffset, frameH/2);
            _firstActorScrollView.contentSize = CGRectMake(self.view.frame.origin.x, frameY, self.view.frame.size.width + (scrollOffset * 2.0), frameH/2).size;
            _firstActorButton.frame = CGRectMake(self.view.frame.origin.x + scrollOffset, self.view.frame.origin.y, self.view.frame.size.width, frameH/2);
            _firstActorActionView.frame = CGRectMake(frameX, frameY, frameW + scrollOffset, frameH/2);
            
            _secondActorScrollView.frame = CGRectMake(self.view.frame.origin.x - scrollOffset, frameY + frameH/2, self.view.frame.size.width + scrollOffset, frameH/2);
            _secondActorScrollView.contentSize = CGRectMake(self.view.frame.origin.x, frameY, self.view.frame.size.width + (scrollOffset * 2.0), frameH/2).size;
            _secondActorButton.frame = CGRectMake(self.view.frame.origin.x + scrollOffset, self.view.frame.origin.y, self.view.frame.size.width, frameH/2);
        }
        
        _firstActorScrollView.contentInset = UIEdgeInsetsMake(0, scrollOffset, 0, 0);
        _firstActorScrollView.pagingEnabled = YES;
        _firstActorScrollView.showsHorizontalScrollIndicator = NO;
        _firstActorScrollView.bounces = NO;
        _firstActorScrollView.delegate = self;
        
        _secondActorScrollView.contentInset = UIEdgeInsetsMake(0, scrollOffset, 0, 0);
        _secondActorScrollView.pagingEnabled = YES;
        _secondActorScrollView.showsHorizontalScrollIndicator = NO;
        _secondActorScrollView.bounces = NO;
        _secondActorScrollView.delegate = self;
        
        // Buttons
        _secondActorButton.backgroundColor = [UIColor blueColor];
        
        _thatMovieWithButton.frame = self.view.frame;
        _thatMovieShimmeringView.frame = self.view.frame;
        _thatMovieWithButton.tintColor = [UIColor whiteColor];
        
        _andButton.frame = CGRectMake(frameX, frameY + frameH/2, frameW, frameH/2);
        _andShimmeringView.frame = CGRectMake(frameX, frameY + frameH/2, frameW, frameH/2);
        _andButton.tintColor = [UIColor whiteColor];
        
        _thatMovieShimmeringView.shimmeringPauseDuration = 0.6;
        _thatMovieShimmeringView.shimmeringSpeed = 100;
        _thatMovieShimmeringView.contentView = _thatMovieWithButton;
        _thatMovieShimmeringView.shimmering = YES;
        _andShimmeringView.shimmeringPauseDuration = 0.6;
        _andShimmeringView.shimmeringSpeed = 100;
        _andShimmeringView.contentView = _andButton;
        _andShimmeringView.shimmering = YES;
        _andButton.hidden = YES;
        
        
        // Labels
        _firstActorLabel.hidden = NO;
        _firstActorLabel.textColor = [UIColor whiteColor];
        _firstActorLabel.textAlignment = NSTextAlignmentCenter;
        _firstActorLabel.frame = CGRectMake(self.view.bounds.origin.x + scrollOffset, self.view.bounds.origin.y-5, self.view.bounds.size.width, self.view.bounds.size.height/2);
        
        _secondActorLabel.hidden = NO;
        _secondActorLabel.textColor = [UIColor whiteColor];
        _secondActorLabel.textAlignment = NSTextAlignmentCenter;
        _secondActorLabel.frame = CGRectMake(self.view.bounds.origin.x + scrollOffset, self.view.bounds.origin.y-5, self.view.bounds.size.width, self.view.bounds.size.height/2);
        
        // Action slide views and labels
        _firstActorActionView.backgroundColor = [UIColor grayColor];
        
        _secondActorActionView.frame = CGRectMake(frameX, frameY + frameH/2, frameW + scrollOffset, frameH/2);
        _secondActorActionView.backgroundColor = [UIColor grayColor];
        
        _firstActorActionLabel.frame = CGRectMake(self.view.frame.size.width - 100, frameY, 100, frameH/2);
        _firstActorActionLabel.text = moviesSlideString;
        _firstActorActionLabel.numberOfLines = 2;
        _firstActorActionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:24];
        _firstActorActionLabel.textAlignment = NSTextAlignmentCenter;
        
        _secondActorActionLabel.frame = CGRectMake(self.view.frame.size.width - 100, frameY, 100, frameH/2);
        _secondActorActionLabel.text = moviesSlideString;
        _secondActorActionLabel.numberOfLines = 2;
        _secondActorActionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:24];
        _secondActorActionLabel.textAlignment = NSTextAlignmentCenter;
        
        _firstActorDeleteLabel.frame = CGRectMake(5, frameY, 100, frameH/2);
        _firstActorDeleteLabel.text = deleteSlideString;
        _firstActorDeleteLabel.numberOfLines = 2;
        _firstActorDeleteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:24];
        _firstActorDeleteLabel.textAlignment = NSTextAlignmentCenter;
        
        _secondActorDeleteLabel.frame = CGRectMake(5, frameY, 100, frameH/2);
        _secondActorDeleteLabel.text = deleteSlideString;
        _secondActorDeleteLabel.numberOfLines = 2;
        _secondActorDeleteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:24];
        _secondActorDeleteLabel.textAlignment = NSTextAlignmentCenter;
        
        // Make the buttons bounce when added
        [self addRightBounceBehavior];
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _curtainView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background-blur" ofType:@"jpg"]]];
    _statusBarView = [UIView new];
    _firstActorScrollView = [UIScrollView new];
    _secondActorScrollView = [UIScrollView new];
    _firstActorButton = [UIButton new];
    _secondActorButton = [UIButton new];
    _thatMovieShimmeringView = [FBShimmeringView new];
    _andShimmeringView = [FBShimmeringView new];
    _firstActorLabel = [UILabel new];
    _secondActorLabel = [UILabel new];
    _firstActorActionView = [UIView new];
    _secondActorActionView = [UIView new];
    _firstActorActionLabel = [UILabel new];
    _secondActorActionLabel = [UILabel new];
    _firstActorDeleteLabel = [UILabel new];
    _secondActorDeleteLabel = [UILabel new];
    
    //_curtainView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _curtainView.contentMode = UIViewContentModeScaleAspectFill;
    [_curtainView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [_curtainView.image applyVeryDarkCurtainEffect];
    
    // Buttons
    [_firstActorButton addTarget:self
                          action:@selector(buttonPressed:)
                forControlEvents:UIControlEventTouchUpInside];
    _firstActorButton.hidden = YES;
    [_secondActorButton addTarget:self
                           action:@selector(buttonPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
    _secondActorButton.hidden = YES;
    
    // Tag the actor buttons so they can be identified when pressed
    _firstActorButton.tag = 1;
    _secondActorButton.tag = 2;
    _thatMovieWithButton.tag = 1;
    _andButton.tag = 2;
    
    [self.view insertSubview:_curtainView atIndex:0];
    [self.view insertSubview:_statusBarView aboveSubview:_curtainView];
    [self.view addSubview:_firstActorScrollView];
    [self.view insertSubview:_secondActorScrollView belowSubview:_firstActorScrollView];
    [_firstActorScrollView addSubview:_firstActorButton];
    [_secondActorScrollView addSubview:_secondActorButton];
    [self.view addSubview:_thatMovieShimmeringView];
    [self.view bringSubviewToFront:_thatMovieWithButton];
    [self.view insertSubview:_andShimmeringView belowSubview:_thatMovieShimmeringView];
    [_firstActorScrollView addSubview:_firstActorLabel];
    [_secondActorScrollView addSubview:_secondActorLabel];
    [_firstActorActionView addSubview:_firstActorActionLabel];
    [_secondActorActionView addSubview:_secondActorActionLabel];
    [_firstActorActionView addSubview:_firstActorDeleteLabel];
    [_secondActorActionView addSubview:_secondActorDeleteLabel];
    
    _thatMovieWithButton.alpha = 0.0;
    [UIView animateWithDuration:0.5
                          delay:0
                        options:0
                     animations:^(void) {
                         self.thatMovieWithButton.alpha = 1.0;
                     }
                     completion:nil];
    
    
    // Get the base TMDB API URL string
    [self loadImageConfiguration];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    (actor1 != nil) ? [self hideStatusBar] : [self showStatusBar];
    
	// hide navigation bar
	[self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // Make the keyboard black
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
    // Make the search bar text white
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor grayColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor goldColor]];
    // Cancel button
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor goldColor]];
    NSDictionary *fontDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0], NSFontAttributeName, [UIColor goldColor], NSForegroundColorAttributeName, nil];
    [[UIBarButtonItem appearance] setTitleTextAttributes:fontDict forState:UIControlStateNormal];
    
    [self.navigationController.navigationBar.backItem.backBarButtonItem setImageInsets:UIEdgeInsetsMake(40, 40, -40, 40)];
    [self.navigationController.navigationBar setBackIndicatorImage:
     [UIImage imageNamed:@"arrow"]];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:
     [UIImage imageNamed:@"arrow"]];
    
    
    if (actor2 != nil) {
        [self removeInfoButton];
    }
}

// Captures the current screen and blurs it
- (void)blurScreen {
    
    UIScreen *screen = [UIScreen mainScreen];
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, screen.scale);
    
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurImage = [snapshot applyDarkEffect];
    UIGraphicsEndImageContext();
    
    // Blur the current screen
    _blurImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _blurImageView.image = blurImage;
    _blurImageView.contentMode = UIViewContentModeBottom;
    _blurImageView.clipsToBounds = YES;
    [self.view addSubview:_blurImageView];
    
}

#pragma mark Private Methods

- (void)hideStatusBar
{
    if([[UIApplication sharedApplication] respondsToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

- (void)showStatusBar
{
    if([[UIApplication sharedApplication] respondsToSelector:@selector(setStatusBarHidden:)]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (void)removeInfoButton
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"removeInfoButton"
     object:self];
}

- (void)addInfoButton
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"addInfoButton"
     object:self];
}

// Blur the background and bring up the search bar
- (void)searchForActor
{
    hasSearched = YES;
    // Blur the current screen
    [self blurScreen];
    // Put the search bar in front of the blurred view
    [self.view bringSubviewToFront:_searchBar];
    
    // Show the search bar
    _searchBar.hidden = NO;
    _searchBar.translucent = YES;
    _searchBar.backgroundImage = [UIImage new];
    _searchBar.scopeBarBackgroundImage = [UIImage new];
    [_searchBar becomeFirstResponder];
    [self.searchDisplayController setActive:YES animated:YES];
    
}

- (void)removeActor
{
    switch (tappedActor) {
            
        case 1:
        {
            if ([self.firstActorActionView isDescendantOfView:self.view]) {
                [self.firstActorActionView removeFromSuperview];
            }
            if (actor1 != nil) {
                [[TMWActorContainer actorContainer] removeActorObject:actor1];
                actor1 = nil;
            }
            _firstActorButton.hidden = NO;
            [self.view bringSubviewToFront:_firstActorButton];
            [self.view bringSubviewToFront:_firstActorLabel];
            [self.view bringSubviewToFront:_thatMovieWithButton];
            [self.view bringSubviewToFront:_thatMovieShimmeringView];
            _firstActorActionView.hidden = YES;
            _thatMovieWithButton.hidden = NO;
            _thatMovieShimmeringView.hidden = NO;
            
            break;
        }
        case 2:
        {
            if ([self.secondActorActionView isDescendantOfView:self.view]) {
                [self.secondActorActionView removeFromSuperview];
            }
            if (actor2 != nil) {
                [[TMWActorContainer actorContainer] removeActorObject:actor2];
                actor2 = nil;
            }
            _secondActorButton.hidden = NO;
            [self.view bringSubviewToFront:_secondActorButton];
            [self.view bringSubviewToFront:_secondActorLabel];
            [self.view bringSubviewToFront:_andButton];
            [self.view bringSubviewToFront:_andShimmeringView];
            _secondActorActionView.hidden = YES;
            _andButton.hidden = NO;
            _andShimmeringView.hidden = NO;
            break;
        }
    }
    // // Only hide the continue button if there are not actors
    if ([TMWActorContainer actorContainer].allActorObjects.count == 0) {
        _andButton.hidden = YES;
        _thatMovieWithButton.frame = self.view.frame;
        _thatMovieShimmeringView.frame = self.view.frame;
        _firstActorActionView.hidden = YES;
        _secondActorActionView.hidden = YES;
        [self.view bringSubviewToFront:_thatMovieShimmeringView];
    }
    else {
        
        _thatMovieWithButton.frame = CGRectMake(frameX, frameY, frameW, frameH/2);
        _thatMovieShimmeringView.frame = CGRectMake(frameX, frameY, frameW, frameH/2);
    }
}

- (void)loadImageConfiguration
{
    __block CWStatusBarNotification *notification = [CWStatusBarNotification new];
    notification.notificationLabelBackgroundColor = [UIColor flatRedColor];
    notification.notificationLabelTextColor = [UIColor whiteColor];
    notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbConfiguration withParameters:nil andResponseBlock:^(id response, NSError *error) {
        
        if (!error) {
            [TMWActorContainer actorContainer].backdropSizes = response[@"images"][@"logo_sizes"];
            [TMWActorContainer actorContainer].imagesBaseURLString = [response[@"images"][@"base_url"] stringByAppendingString:[TMWActorContainer actorContainer].backdropSizes[1]];
        }
        else {
            if ([error.localizedDescription rangeOfString:@"NSURLErrorDomain error -999"].location == NSNotFound) {
                [notification displayNotificationWithMessage:@"Network Error. Check your network connection." forDuration:3.0f];
            }
        }
    }];
}

- (void)refreshActorResponseWithJLTMDBcall:(NSDictionary *)call
{
    NSString *JLTMDBCall = call[@"JLTMDBCall"];
    NSDictionary *parameters = call[@"parameters"];
    
    __block CWStatusBarNotification *notification = [CWStatusBarNotification new];
    notification.notificationLabelBackgroundColor = [UIColor flatRedColor];
    notification.notificationLabelTextColor = [UIColor whiteColor];
    notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    
    [[JLTMDbClient sharedAPIInstance] GET:JLTMDBCall withParameters:parameters andResponseBlock:^(id response, NSError *error) {
        if (!error) {
            NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
            [operationQueue addOperationWithBlock:^{
                TMWActorSearchResults *previousSearchResults = [TMWActorSearchResults new];
                previousSearchResults = searchResults;
                newSearchResults = [[TMWActorSearchResults alloc] initActorSearchResultsWithResults:response[@"results"]];
                [self refreshSearchControllerWithOldSearchResults:previousSearchResults.results andNewResults:newSearchResults.results];
            }];
        }
        else {
            if ([error.localizedDescription rangeOfString:@"NSURLErrorDomain error -999"].location == NSNotFound) {
                [notification displayNotificationWithMessage:@"Network Error. Check your network connection." forDuration:3.0f];
            }
        }
    }];
}

- (void)refreshSearchControllerWithOldSearchResults:(NSArray *)oldResultsArray andNewResults:(NSArray *)newResultsArray
{
    if (oldResultsArray == nil) {
        oldResultsArray = [NSArray new];
    }
    
    // If rows are removed
    if (newResultsArray.count < oldResultsArray.count && oldResultsArray.count) {
        NSMutableArray *diferentIndexes = [NSMutableArray new];
        for (NSUInteger i = 0; i < newResultsArray.count; i++) {
            if (oldResultsArray[i] != newResultsArray[i]) { //Maybe add "&& newSearchResultsArray.count" here
                [diferentIndexes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        
        NSMutableArray *oldIndexes = [NSMutableArray new];
        if (newResultsArray.count < oldResultsArray.count) {
            for (NSUInteger i = newResultsArray.count; i < oldResultsArray.count; i++) {
                [oldIndexes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        
        // Update the table view
        dispatch_async(dispatch_get_main_queue(),^{
            [[self.searchBarController searchResultsTableView] beginUpdates];
            [[self.searchBarController searchResultsTableView] numberOfRowsInSection:newResultsArray.count];
            [[self.searchBarController searchResultsTableView] deleteRowsAtIndexPaths:oldIndexes withRowAnimation:UITableViewRowAnimationFade];
            searchResults = newSearchResults;
            [[self.searchBarController searchResultsTableView] endUpdates];
        });
    }
    
    
    // If rows are added
    else if (newResultsArray.count > oldResultsArray.count && oldResultsArray.count != 0) {
        NSMutableArray *diferentIndexes = [NSMutableArray new];
        for (NSUInteger i = 0; i < oldResultsArray.count; i++) {
            if (oldResultsArray[i] != newResultsArray[i]) { //Maybe add "&& newSearchResultsArray.count" here
                [diferentIndexes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        NSMutableArray *newIndexes = [NSMutableArray new];
        if (newResultsArray.count > oldResultsArray.count) {
            NSUInteger index;
            if (!oldResultsArray.count) index = 0; else index = oldResultsArray.count;
            for (NSUInteger i = index; i < newResultsArray.count; i++) {
                [newIndexes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        
        // Update the table view
        dispatch_async(dispatch_get_main_queue(),^{
            [[self.searchBarController searchResultsTableView] beginUpdates];
            [[self.searchBarController searchResultsTableView] insertRowsAtIndexPaths:newIndexes withRowAnimation:UITableViewRowAnimationFade];
            searchResults = newSearchResults;
            [[self.searchBarController searchResultsTableView] endUpdates];
        });
    }
    
    // Rows are just changed
    else if (newResultsArray.count == oldResultsArray.count && oldResultsArray.count != 0) {
        NSMutableArray *diferentIndexes = [NSMutableArray new];
        for (NSUInteger i = 0; i < oldResultsArray.count; i++) {
            if (oldResultsArray[i] != newResultsArray[i]) { //Maybe add "&& newSearchResultsArray.count" here
                [diferentIndexes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        
        // Update the table view
        dispatch_async(dispatch_get_main_queue(),^{
            [[self.searchBarController searchResultsTableView] beginUpdates];
            [[self.searchBarController searchResultsTableView] reloadRowsAtIndexPaths:diferentIndexes withRowAnimation:UITableViewRowAnimationFade];
            searchResults = newSearchResults;
            [[self.searchBarController searchResultsTableView] endUpdates];
        });
    }
    
    // If entire view needs refreshed
    else if (oldResultsArray.count == 0) {
        dispatch_async(dispatch_get_main_queue(),^{
            [[self.searchBarController searchResultsTableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        });
        searchResults = newSearchResults;
    }
}

- (void)setLabel:(UILabel *)textView
      withString:(NSString *)string
  inBoundsOfView:(UIView *)view
{
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    UIFont *textFont = [UIFont new];
    
    textFont = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:ACTOR_FONT_SIZE];
    
    NSDictionary *attributes = @{NSFontAttributeName:textFont, NSParagraphStyleAttributeName: textStyle};
    CGRect bound = [string boundingRectWithSize:CGSizeMake(view.bounds.size.width-20, view.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    textView.numberOfLines = 4;
    textView.font = textFont;
    textView.bounds = bound;
    textView.text = string;
}


- (void)animateScrollViewBoundsChange:(UIScrollView *)scrollView
{
    CGRect bounds = scrollView.bounds;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    animation.fromValue = [NSValue valueWithCGRect:bounds];
    
    bounds.origin.x += scrollOffset;
    
    animation.toValue = [NSValue valueWithCGRect:bounds];
    
    [scrollView.layer addAnimation:animation forKey:@"bounds"];
    
    scrollView.bounds = bounds;
}

- (void)addRightBounceBehavior
{
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[_firstActorScrollView, _secondActorScrollView]];
    // Using 0.5 for right inset due to edgeInsets bug
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -280, 0, 0.5)];
    [_animator addBehavior:collisionBehaviour];
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[_firstActorScrollView, _secondActorScrollView]];
    self.gravityBehavior.gravityDirection = CGVectorMake(1.0f, 0.0f);
    [_animator addBehavior:self.gravityBehavior];
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[_firstActorScrollView, _secondActorScrollView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.magnitude = 0.0f;
    self.pushBehavior.angle = 0.0f;
    [_animator addBehavior:self.pushBehavior];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[_firstActorScrollView, _secondActorScrollView]];
    itemBehaviour.elasticity = 0.6f;
    [_animator addBehavior:itemBehaviour];
}

- (void)refreshSearchTableView
{
    [[self.searchBarController searchResultsTableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)SVProgressHUDShow
{
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor grayColor]];
    //[SVProgressHUD setRingNoTextRadius:48];
    if (doneLoadingActorImage) return;
    if (tappedActor == 1) {
        [SVProgressHUD showAtPosY:self.view.frame.size.height/4];
    }
    else {
        [SVProgressHUD showAtPosY:3 * (self.view.frame.size.height/4)];
    }
}

#pragma mark UIScrollView methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _firstActorScrollView) {
        _firstActorActionView.hidden = NO;
        _firstActorDeleteLabel.text = deleteSlideString;
        _firstActorActionLabel.text = moviesSlideString;
        _firstActorDeleteLabel.alpha = fabs((scrollView.contentOffset.x)/100.0);
        _firstActorActionView.alpha = fabs((scrollView.contentOffset.x)/100.0);
        _firstActorActionLabel.alpha = fabs((scrollView.contentOffset.x)/100.0);
        if (-1 * scrollView.contentOffset.x > abs((int)scrollOffset/2)) {
            _firstActorActionView.backgroundColor = [UIColor flatRedColor];
        }
        else {
            _firstActorActionView.backgroundColor = [UIColor flatRedColor];
        }
    }
    
    else if (scrollView == _secondActorScrollView) {
        _secondActorActionView.hidden = NO;
        _secondActorDeleteLabel.text = deleteSlideString;
        _secondActorActionLabel.text = moviesSlideString;
        _secondActorDeleteLabel.alpha = fabs((scrollView.contentOffset.x)/100.0);
        _secondActorActionView.alpha = fabs((scrollView.contentOffset.x)/100.0);
        _secondActorActionLabel.alpha = fabs((scrollView.contentOffset.x)/100.0);
        if (-1 * scrollView.contentOffset.x > abs((int)scrollOffset/2)) {
            _secondActorActionView.backgroundColor = [UIColor flatRedColor];
        }
        else {
            _secondActorActionView.backgroundColor = [UIColor flatRedColor];
        }
        // Make sure the actor image and label are on top
        [self.view sendSubviewToBack:_secondActorActionView];
        [self.view sendSubviewToBack:_curtainView];
    }
    
    if (_firstActorScrollView.contentOffset.x > 0 || _secondActorScrollView.contentOffset.x > 0) {
        _secondActorScrollView.contentOffset = scrollView.contentOffset;
        _firstActorScrollView.contentOffset = scrollView.contentOffset;
        _firstActorActionView.backgroundColor = [UIColor flatGreenColor];
        _secondActorActionView.backgroundColor = [UIColor flatGreenColor];
        
        if (!_firstActorButton.isHidden && !_secondActorButton.isHidden) {
            _firstActorActionView.hidden = NO;
            _secondActorActionView.hidden = NO;
            _firstActorActionLabel.frame = CGRectMake(self.view.frame.size.width - 100, _firstActorScrollView.frame.size.height/2, 100, _firstActorScrollView.frame.size.height);
            _firstActorActionLabel.text = @"Common Movies";
            
            // Rearrange all the subviews again
            [self.view bringSubviewToFront:_secondActorActionView];
            [self.view bringSubviewToFront:_firstActorActionView];
            [self.view bringSubviewToFront:_secondActorScrollView];
            [self.view bringSubviewToFront:_firstActorScrollView];
            
            [_secondActorScrollView bringSubviewToFront:_secondActorButton];
            [_secondActorScrollView bringSubviewToFront:_secondActorLabel];
            [_firstActorScrollView bringSubviewToFront:_firstActorButton];
            [_firstActorScrollView bringSubviewToFront:_firstActorLabel];
            _secondActorActionLabel.text = nil;
            
        }
        else {
            _firstActorActionLabel.frame = CGRectMake(self.view.frame.size.width - 100, frameY, 100, frameH/2);
            _secondActorActionLabel.frame = CGRectMake(self.view.frame.size.width - 100, frameY, 100, frameH/2);
        }
    }
    
    // Common movies sound
    if (scrollView.contentOffset.x > scrollOffset - 20 && pastSoundThreshold == NO) {
        pastSoundThreshold = YES;
        [[TMWSoundEffects soundEffects] playSound:@"When swipe transition to movies screen begins"];
    }
    // Delete sound
    else if (-1 * scrollView.contentOffset.x > abs((int)scrollOffset - 20) && pastSoundThreshold == NO) {
        pastSoundThreshold = YES;
        [[TMWSoundEffects soundEffects] playSound:@"When swipe transition to delete actor begins"];
    }
    else if (!((-1 * scrollView.contentOffset.x > abs((int)scrollOffset - 20)) || (scrollView.contentOffset.x > scrollOffset - 20))) {
        pastSoundThreshold = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (scrollView == _firstActorScrollView) {
        
        // Move the other actor back into its original position
        if (_secondActorScrollView.contentOffset.x != 0) {
            // Set the delete view frame depending on the actors chosen
            if (self.firstActorLabel.text && ![self.firstActorActionView isDescendantOfView:self.view]) {
                [self.view insertSubview:self.firstActorActionView atIndex:1];
                self.firstActorActionView.alpha = 1.0;
                self.firstActorActionView.backgroundColor = [UIColor flatGreenColor];
            }
            [self animateScrollViewBoundsChange:_secondActorScrollView];
        }
    }
    
    if (scrollView == _secondActorScrollView) {
        // Move the other actor back into its original position
        if (_firstActorScrollView.contentOffset.x != 0) {
            if (self.secondActorLabel.text && ![self.secondActorActionView isDescendantOfView:self.view]) {
                [self.view insertSubview:self.secondActorActionView belowSubview:self.firstActorActionView];
                self.secondActorActionLabel.alpha = 1.0;
                self.secondActorActionView.backgroundColor = [UIColor flatGreenColor];
            }
            [self animateScrollViewBoundsChange:_firstActorScrollView];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView == _firstActorScrollView || scrollView == _secondActorScrollView) {
        if (scrollView.contentOffset.x > scrollOffset - 20) {
            
            // Play transition sound
            [[TMWSoundEffects soundEffects] playSound:@"During transition to movies screen"];
            
            // Show the Movies View
            TMWMoviesCollectionViewController *moviesViewController = [[TMWMoviesCollectionViewController alloc] init];
            [self.navigationController pushViewController:moviesViewController animated:YES];
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    }
    
    if (scrollView == _firstActorScrollView) {
        if (-1 * scrollView.contentOffset.x > abs((int)scrollOffset - 20)) {
            tappedActor = 1;
            [self removeActor];
            [[TMWSoundEffects soundEffects] playSound:@"During deletion of actor"];
            [self showStatusBar];
            
            self.thatMovieWithButton.alpha = 0.0;
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                             animations:^(void) {
                                 self.firstActorButton.alpha = 0.0;
                                 self.firstActorScrollView.alpha = 0.0;
                             }
                             completion:^(BOOL finished)
             {
                 self.firstActorButton.imageView.image = nil;
                 self.firstActorButton.hidden = YES;
                 self.firstActorLabel.text = nil;
                 self.firstActorScrollView.alpha = 1.0;
                 self.firstActorButton.alpha = 1.0;
                 self.firstActorActionView.hidden = YES;
                 [UIView animateWithDuration:0.25
                                       delay:0
                                     options:0
                                  animations:^(void) {
                                      self.thatMovieWithButton.alpha = 1.0;
                                  }
                                  completion:nil];
             }];
            
            [self.view bringSubviewToFront:_thatMovieWithButton];
        }
    }
    
    if (scrollView == _secondActorScrollView) {
        if (-1 * scrollView.contentOffset.x > abs((int)scrollOffset - 20)) {
            tappedActor = 2;
            [self removeActor];
            [[TMWSoundEffects soundEffects] playSound:@"During deletion of actor"];
            self.andButton.alpha = 0.0;
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                             animations:^(void) {
                                 self.secondActorButton.alpha = 0.0;
                                 self.secondActorScrollView.alpha = 0.0;
                             }
                             completion:^(BOOL finished)
             {
                 self.secondActorButton.imageView.image = nil;
                 self.secondActorButton.hidden = YES;
                 self.secondActorLabel.text = nil;
                 self.secondActorScrollView.alpha = 1.0;
                 self.secondActorButton.alpha = 1.0;
                 self.secondActorActionView.hidden = YES;
                 [self addInfoButton];
                 [UIView animateWithDuration:0.25
                                       delay:0
                                     options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                                  animations:^(void) {
                                      self.andButton.alpha = 1.0;
                                  }
                                  completion:nil];
             }];
            
            [self.view bringSubviewToFront:_andButton];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _firstActorScrollView.contentOffset = CGPointMake(0, 0);
    _secondActorScrollView.contentOffset = CGPointMake(0, 0);
}


#pragma mark UISearchBar methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchBarController.searchResultsTableView setContentOffset:CGPointMake(self.searchBarController.searchResultsTableView.contentOffset.x, 0) animated:YES];
    
    // Delays on making the actor API calls
    if([searchText length] != 0) {
        float delay = 0.8;
        
        if (searchText.length > 3) {
            delay = 0.6;
        }
        //[[JLTMDbClient sharedAPIInstance].operationQueue cancelAllOperations];
        
        // Clear any previously queued text changes
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        [self performSelector:@selector(refreshActorResponseWithJLTMDBcall:)
                   withObject:@{@"JLTMDBCall":kJLTMDbSearchPerson, @"parameters":@{@"search_type":@"ngram",@"query":searchText}}
                   afterDelay:delay];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Hide the search bar when searching is completed
    [self.searchDisplayController setActive:NO animated:NO];
    _searchBar.hidden = YES;
    [_blurImageView removeFromSuperview];
    
    [[JLTMDbClient sharedAPIInstance].operationQueue cancelAllOperations];
    if (actor1 != nil) [self hideStatusBar];
    if (actor2 != nil) [self removeInfoButton];
    
    // Play sound
    [[TMWSoundEffects soundEffects] playSound:@"When cancel button is clicked in actor search"];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [[JLTMDbClient sharedAPIInstance].operationQueue cancelAllOperations];
    return TRUE;
}


#pragma mark UISearchDisplayController methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        for (UIView *v in controller.searchResultsTableView.subviews) {
            if ([v isKindOfClass:[UILabel self]]) {
                ((UILabel *)v).font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];;
                break;
            }
        }
    });
    return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self removeInfoButton];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self showStatusBar];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    // Make the background of the search results transparent
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    controller.searchResultsTableView.backgroundView = backView;
    controller.searchResultsTableView.backgroundColor = [UIColor clearColor];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    // Hide the search bar when searching is completed
    [self.searchDisplayController setActive:NO animated:NO];
    _searchBar.hidden = YES;
    [_blurImageView removeFromSuperview];
    [self addInfoButton];
}

#pragma mark UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [searchResults.names count];
}

// Change the Height of the Cell [Default is 44]:
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return TABLE_HEIGHT;
}

// Todo: add fade in animation to searching
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    [[UITableViewCell appearance] setBackgroundColor:[UIColor clearColor]];
    
    TMWCustomActorCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[TMWCustomActorCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:CellIdentifier];
        [cell layoutSubviews];
    }
    
    // Set the line separator left offset to start after the image
    [_searchBarController.searchResultsTableView setSeparatorInset:UIEdgeInsetsMake(0, IMAGE_SIZE+IMAGE_TEXT_OFFSET, 0, 0)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(TMWCustomActorCellTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
    
    // Make the actors images circles in the search table view
    cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height/2;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderWidth = 0;
    
    // Make the search table view test and cell separators white
    cell.textLabel.text = [searchResults.names objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    tableView.separatorColor = [UIColor goldColor];
    
    // If NSString, fetch the image, else use the generated UIImage
    if ([[searchResults.lowResImageEndingURLs objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        
        NSString *urlstring = [[TMWActorContainer actorContainer].imagesBaseURLString stringByAppendingString:[searchResults.lowResImageEndingURLs objectAtIndex:indexPath.row]];
        
        // Show the network activity icon
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        __weak TMWCustomActorCellTableViewCell *weakCell = cell;
        __block CWStatusBarNotification *notification = [CWStatusBarNotification new];
        notification.notificationLabelBackgroundColor = [UIColor flatRedColor];
        notification.notificationLabelTextColor = [UIColor whiteColor];
        notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
        notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
        
        // Get the image from the URL and set it
        [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]] placeholderImage:[UIImage imageNamed:@"black"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            // Hide the network activity icon
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            if (request) {
                [UIView transitionWithView:weakCell.imageView
                                  duration:0.0f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{[weakCell.imageView setImage:image];}
                                completion:NULL];
            }
            else {
                weakCell.imageView.image = image;
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            if ([error.localizedDescription rangeOfString:@"NSURLErrorDomain error -999"].location == NSNotFound) {
                [notification displayNotificationWithMessage:@"Network Error. Check your network connection." forDuration:3.0f];
            }
            // Hide the network activity icon
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        
        
    }
    else {
        UIImage *defaultImage = [UIImage imageByDrawingInitialsOnImage:[UIImage imageNamed:@"InitialsBackgroundLowRes.png"] withInitials:[searchResults.names objectAtIndex:indexPath.row] withFontSize:16];
        [cell.imageView setImage:defaultImage];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchDisplayController setActive:NO animated:NO];
    
    TMWActor *chosenActor = [[TMWActor alloc] initWithActor:[searchResults.results objectAtIndex:indexPath.row]];
    
    // Remove an actor if one was chosen
    [self removeActor];
    
    // Add the chosen actor to the array of chosen actors
    [[TMWActorContainer actorContainer] addActorObject:chosenActor];
    
    // Cancel any previous search requests
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // Clear the search results
    [searchResults removeAllObjects];
    
    if (tappedActor == 1)
    {
        // The second actor is the default selection for being replaced.
        [self configureActor:chosenActor
                  withButton:_firstActorButton
                    andLabel:_firstActorLabel
                 atIndexPath:indexPath];
        
        // Show the second actor information
        actor1 = chosenActor;
        _thatMovieWithButton.hidden = YES;
        _thatMovieShimmeringView.hidden = YES;
        _firstActorScrollView.hidden = NO;
        //_firstActorLabel.hidden = YES;
        if ([TMWActorContainer actorContainer].allActorObjects.count == 1) {
            [self.view bringSubviewToFront:_andButton];
            _andButton.hidden = NO;
            _secondActorButton.hidden = YES;
        }
    }
    else
    {
        // The second actor is the default selection for being replaced.
        [self configureActor:chosenActor
                  withButton:_secondActorButton
                    andLabel:_secondActorLabel
                 atIndexPath:indexPath];
        
        // Enable dragging the actor around
        //secondPanGesture.enabled = YES;
        _secondActorButton.hidden = NO;
        _secondActorScrollView.hidden = NO;
        _andShimmeringView.hidden = YES;
        [self removeInfoButton];
        _andButton.hidden = YES;
        actor2 = chosenActor;
    }
    [self hideStatusBar];
    
    if ([TMWActorContainer actorContainer].allActorObjects.count == 2) [self removeInfoButton];
}

// Set the actor image and all of it's necessary properties
- (void)configureActor:(TMWActor *)actor
            withButton:(UIButton *)button
              andLabel:(UILabel *)label
           atIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *actorImage = [UIImageView new];
    actorImage.contentMode = UIViewContentModeScaleAspectFill;
    
    [button addSubview:actorImage];
    
    actorImage.frame = button.bounds;
    button.clipsToBounds = NO;
    
    label.hidden = YES;
    
    doneLoadingActorImage = NO;
    
    [self performSelector:@selector(SVProgressHUDShow) withObject:nil afterDelay:0.3];
    
    // If NSString, fetch the image, else use the generated UIImage
    if ([actor.hiResImageURLEnding isKindOfClass:[NSString class]]) {
        
        NSString *urlstring = [[[TMWActorContainer actorContainer].imagesBaseURLString stringByReplacingOccurrencesOfString:[TMWActorContainer actorContainer].backdropSizes[1] withString:[TMWActorContainer actorContainer].backdropSizes[5]] stringByAppendingString:actor.hiResImageURLEnding];
        
        __block CWStatusBarNotification *notification = [CWStatusBarNotification new];
        notification.notificationLabelBackgroundColor = [UIColor flatRedColor];
        notification.notificationLabelTextColor = [UIColor whiteColor];
        notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
        notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
        
        __weak typeof(actorImage) weakActorImage = actorImage;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]];
        [actorImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"black"] success:^(NSURLRequest *req, NSHTTPURLResponse *response, UIImage *image) {
            
            doneLoadingActorImage = YES;
            
            // Set the image
            weakActorImage.image = image;
            
            // Set the image to the correct context
            UIGraphicsBeginImageContextWithOptions(weakActorImage.bounds.size, weakActorImage.opaque, 0.0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [weakActorImage.layer renderInContext:context];
            UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // Darken the image
            UIImage *darkImage = [screenShot applyPosterEffect];
            
            [button setBackgroundImage:darkImage forState:UIControlStateNormal];
            [weakActorImage removeFromSuperview];
            
            // Set the image label properties to center it in the cell
            [self setLabel:label withString:actor.name inBoundsOfView:button];
            label.hidden = NO;
            
            self.firstActorActionView.backgroundColor = [UIColor flatGreenColor];
            self.secondActorActionView.backgroundColor = [UIColor flatGreenColor];
            // Set the delete view frame depending on the actors chosen
            if (self.firstActorLabel.text && ![self.firstActorActionView isDescendantOfView:self.view]) {
                [self.view insertSubview:self.firstActorActionView atIndex:1];
            }
            if (self.secondActorLabel.text && ![self.secondActorActionView isDescendantOfView:self.view]) {
                [self.view insertSubview:self.secondActorActionView belowSubview:self.firstActorActionView];
            }
            
            // Play sound
            [[TMWSoundEffects soundEffects] playSound:@"When actor is added and bounce occurs"];
            
            [SVProgressHUD dismiss];
            
        } failure:^(NSURLRequest *failreq, NSHTTPURLResponse *response, NSError *error) {
            if ([error.localizedDescription rangeOfString:@"NSURLErrorDomain error -999"].location == NSNotFound) {
                [notification displayNotificationWithMessage:@"Network Error. Check your network connection." forDuration:3.0f];
            }
            doneLoadingActorImage = YES;
            [SVProgressHUD dismiss];
        }];
    }
    else {
        doneLoadingActorImage = YES;
        UIImage *defaultImage = [UIImage imageNamed:@"InitialsBackgroundHiRes.png"];
        [actorImage setImage:defaultImage];
        // Get the actor circle initials image with layer and set it to the button background
        UIGraphicsBeginImageContextWithOptions(actorImage.bounds.size, actorImage.opaque, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [actorImage.layer renderInContext:context];
        UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Darken the image
        UIImage *darkImage = [screenShot applyPosterEffect];
        
        [button setBackgroundImage:darkImage forState:UIControlStateNormal];
        [actorImage removeFromSuperview];
        
        // Set the image label properties to center it in the cell
        [self setLabel:label withString:actor.name inBoundsOfView:button];
        label.hidden = NO;
        
        // Set the delete view frame depending on the actors chosen
        if (self.firstActorLabel.text && ![self.firstActorActionView isDescendantOfView:self.view]) {
            [self.view insertSubview:self.firstActorActionView atIndex:1];
        }
        if (self.secondActorLabel.text && ![self.secondActorActionView isDescendantOfView:self.view]) {
            [self.view insertSubview:self.secondActorActionView belowSubview:self.firstActorActionView];
        }
    }
    self.pushBehavior.pushDirection = CGVectorMake(-(self.view.frame.size.width/55.0f) * (self.view.frame.size.width/55.0f), 0.0f);
    self.pushBehavior.active = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

#pragma mark UISearchDisplayController methods

// Added to fix UITableView bottom bounds in UISearchDisplayController
- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// Added to fix UITableView bottom bounds in UISearchDisplayController
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    // If you scroll down in the search table view, this puts it back to the top next time you search
    [self.searchDisplayController.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    // Remove the line separators if there is no results
    self.searchDisplayController.searchResultsTableView.tableFooterView = [UIView new];
}

// Added to fix UITableView bottom bounds in UISearchDisplayController
- (void)keyboardWillHide
{
    UITableView *tableView = [[self searchDisplayController] searchResultsTableView];
    [tableView setContentInset:UIEdgeInsetsMake(0, 0, self.view.frame.size.height/2-TABLE_HEIGHT, 0)];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, self.view.frame.size.height/2-TABLE_HEIGHT, 0)];
}


#pragma mark UIButton methods

-(IBAction)buttonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    // Play sound
    [[TMWSoundEffects soundEffects] playSound:@"When tapping to add an actor"];
    
    switch ([button tag]) {
        case 1: // First actor button
        {
            tappedActor = 1;
            [self searchForActor];
            break;
        }
            
        case 2: // Second actor button
        {
            tappedActor = 2;
            [self searchForActor];
            break;
        }
    }
}

@end
