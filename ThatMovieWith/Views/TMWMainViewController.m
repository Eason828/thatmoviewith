//
//  TMWMainViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 5/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>
#import <POP.h>

#import "TMWMainViewController.h"
#import "TMWActor.h"
#import "TMWActorContainer.h"
#import "TMWActorSearchResults.h"
#import "TMWMoviesCollectionViewController.h"
#import "TMWCustomActorCellTableViewCell.h"

#import "UIImage+ImageEffects.h"
#import "UIColor+customColors.h"
#import "UIImage+DrawOnImage.h"
#import "CALayer+circleLayer.h"

#import "NSMutableArray+SWUtilityButtons.h"

@interface TMWMainViewController () <UIScrollViewDelegate>

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

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;

@end

@implementation TMWMainViewController

static const NSUInteger TABLE_HEIGHT = 66;
static const NSUInteger ACTOR_FONT_SIZE = 42;
NSUInteger scrollOffset;

NSString *moviesSlideString = @"Show\nmovies";
NSString *deleteSlideString = @"Remove\nActor";

TMWActorSearchResults *searchResults;
TMWActor *actor1;
TMWActor *actor2;
int tappedActor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Set the cancel button color in the search bar
        [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor goldColor]];
        
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Actors";
        
        NSString *APIKeyPath = [[NSBundle mainBundle] pathForResource:@"TMDB_API_KEY" ofType:@""];
        
        NSString *APIKeyValueDirty = [NSString stringWithContentsOfFile:APIKeyPath
                                                               encoding:NSUTF8StringEncoding
                                                                  error:NULL];
        
        // Strip whitespace to clean the API key stdin
        NSString *APIKeyValue = [APIKeyValueDirty stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [[JLTMDbClient sharedAPIInstance] setAPIKey:APIKeyValue];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Calls perferredStatusBarStyle
    [self setNeedsStatusBarAppearanceUpdate];
    
    scrollOffset = (self.view.frame.size.width/2) - 20;
    
    // Make the keyboard black
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
    // Make the search bar text white
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor goldColor]];
    
    UIImage *productImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blurCurtain" ofType:@"png"]];
    
    _curtainView = [[UIImageView alloc] initWithImage:productImage];
    
    // Make the frame a little bit bigger for the parallax effect
    _curtainView.frame = CGRectMake(_curtainView.frame.origin.x-16,
                                    _curtainView.frame.origin.y-16,
                                    self.view.frame.size.width+32,
                                    self.view.frame.size.height+32);
    
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-16);
    verticalMotionEffect.maximumRelativeValue = @(16);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-16);
    horizontalMotionEffect.maximumRelativeValue = @(16);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [_curtainView addMotionEffect:group];

    [self.view insertSubview:_curtainView atIndex:0];
    
    float frameX = self.view.frame.origin.x;
    float frameY = self.view.frame.origin.y;
    float frameW = self.view.frame.size.width;
    float frameH = self.view.frame.size.height;

    _firstActorScrollView = [UIScrollView new];
    _firstActorScrollView.frame = CGRectMake(self.view.frame.origin.x - scrollOffset, frameY, self.view.frame.size.width + scrollOffset, frameH/2);
    _firstActorScrollView.contentSize = CGRectMake(self.view.frame.origin.x, frameY, self.view.frame.size.width + (scrollOffset * 2.0), frameH/2).size;
    _firstActorScrollView.contentInset = UIEdgeInsetsMake(0, scrollOffset, 0, 0);
    _firstActorScrollView.pagingEnabled = YES;
    _firstActorScrollView.showsHorizontalScrollIndicator = NO;
    _firstActorScrollView.bounces = NO;
    _firstActorScrollView.delegate = self;
    [self.view addSubview:_firstActorScrollView];

    
    _secondActorScrollView = [UIScrollView new];
    _secondActorScrollView.frame = CGRectMake(self.view.frame.origin.x - scrollOffset, frameY + frameH/2, self.view.frame.size.width + scrollOffset, frameH/2);
    _secondActorScrollView.contentSize = CGRectMake(self.view.frame.origin.x, frameY, self.view.frame.size.width + (scrollOffset * 2.0), frameH/2).size;
    _secondActorScrollView.contentInset = UIEdgeInsetsMake(0, scrollOffset, 0, 0);
    _secondActorScrollView.pagingEnabled = YES;
    _secondActorScrollView.showsHorizontalScrollIndicator = NO;
    _secondActorScrollView.bounces = NO;
    _secondActorScrollView.delegate = self;
    [self.view addSubview:_secondActorScrollView];
    
    
    // Buttons
    _firstActorButton = [UIButton new];
    [_firstActorButton addTarget:self
                          action:@selector(buttonPressed:)
                forControlEvents:UIControlEventTouchUpInside];
    [_firstActorScrollView addSubview:_firstActorButton];
    _firstActorButton.frame = CGRectMake(self.view.frame.origin.x + scrollOffset, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2);
    
    _secondActorButton = [UIButton new];
    [_secondActorButton addTarget:self
                           action:@selector(buttonPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
    _secondActorButton.hidden = YES;
    [_secondActorScrollView addSubview:_secondActorButton];
    _secondActorButton.frame = CGRectMake(self.view.frame.origin.x + scrollOffset, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2);
    
    // Tag the actor buttons so they can be identified when pressed
    _firstActorButton.tag = 1;
    _secondActorButton.tag = 2;
    
    _thatMovieWithButton.tag = 1;
    _thatMovieWithButton.frame = CGRectMake(frameX, frameY + 20, frameW, frameH/2 - 20);
    _thatMovieWithButton.tintColor = [UIColor goldColor];
    CALayer *thatMovieWithLayer = [_thatMovieWithButton layer];
    [thatMovieWithLayer setMasksToBounds:YES];
    [thatMovieWithLayer setCornerRadius:15.0];
    [thatMovieWithLayer setBorderWidth:2.0];
    [thatMovieWithLayer setBorderColor:[[UIColor goldColor] CGColor]];
    
    _andButton.tag = 2;
    _andButton.frame = CGRectMake(frameX, frameY + frameH/2, frameW, frameH/2);
    _andButton.tintColor = [UIColor goldColor];
    CALayer *andLayer = [_andButton layer];
    [andLayer setMasksToBounds:YES];
    [andLayer setCornerRadius:15.0];
    [andLayer setBorderWidth:2.0];
    [andLayer setBorderColor:[[UIColor goldColor] CGColor]];
    _andButton.hidden = YES;
    
    
    // Labels
    _firstActorLabel = [UILabel new];
    _firstActorLabel.hidden = NO;
    _firstActorLabel.textColor = [UIColor whiteColor];
    _firstActorLabel.backgroundColor = [UIColor clearColor];
    _firstActorLabel.textAlignment = NSTextAlignmentCenter;
    _firstActorLabel.frame = CGRectMake(self.view.bounds.origin.x + scrollOffset, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height/2);
    [_firstActorScrollView addSubview:_firstActorLabel];
    
    _secondActorLabel = [UILabel new];
    _secondActorLabel.hidden = NO;
    _secondActorLabel.textColor = [UIColor whiteColor];
    _secondActorLabel.textAlignment = NSTextAlignmentCenter;
    _secondActorLabel.frame = CGRectMake(self.view.bounds.origin.x + scrollOffset, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height/2);
    [_secondActorScrollView addSubview:_secondActorLabel];
    
    
    // Action slide views and labels
    _firstActorActionView = [UIView new];
    _firstActorActionView.frame = CGRectMake(frameX, frameY, frameW + scrollOffset, frameH/2);
    _firstActorActionView.backgroundColor = [UIColor grayColor];
    
    _secondActorActionView = [UIView new];
    _secondActorActionView.frame = CGRectMake(frameX, frameY + frameH/2, frameW + scrollOffset, frameH/2);
    _secondActorActionView.backgroundColor = [UIColor grayColor];
    
    _firstActorActionLabel = [UILabel new];
    _firstActorActionLabel.frame = CGRectMake(self.view.frame.size.width - 80, frameY, 80, frameH/2);
    _firstActorActionLabel.text = moviesSlideString;
    _firstActorActionLabel.numberOfLines = 2;
    _firstActorActionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
    _firstActorActionLabel.textAlignment = NSTextAlignmentCenter;
    [_firstActorActionView addSubview:_firstActorActionLabel];
    
    _secondActorActionLabel = [UILabel new];
    _secondActorActionLabel.frame = CGRectMake(self.view.frame.size.width - 80, frameY, 80, frameH/2);
    _secondActorActionLabel.text = moviesSlideString;
    _secondActorActionLabel.numberOfLines = 2;
    _secondActorActionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
    _secondActorActionLabel.textAlignment = NSTextAlignmentCenter;
    [_secondActorActionView addSubview:_secondActorActionLabel];

    _firstActorDeleteLabel = [UILabel new];
    _firstActorDeleteLabel.frame = CGRectMake(5, frameY, 80, frameH/2);
    _firstActorDeleteLabel.text = deleteSlideString;
    _firstActorDeleteLabel.numberOfLines = 2;
    _firstActorDeleteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
    _firstActorDeleteLabel.textAlignment = NSTextAlignmentCenter;
    [_firstActorActionView addSubview:_firstActorDeleteLabel];
    
    _secondActorDeleteLabel = [UILabel new];
    _secondActorDeleteLabel.frame = CGRectMake(5, frameY, 80, frameH/2);
    _secondActorDeleteLabel.text = deleteSlideString;
    _secondActorDeleteLabel.numberOfLines = 2;
    _secondActorDeleteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
    _secondActorDeleteLabel.textAlignment = NSTextAlignmentCenter;
    [_secondActorActionView addSubview:_secondActorDeleteLabel];
    
    [self addRightBounceBehavior];
    
    // Get the base TMDB API URL string
    [self loadImageConfiguration];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    // Hide the navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
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

// Blur the background and bring up the search bar
- (void)searchForActor
{
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
            [[TMWActorContainer actorContainer] removeActorObject:actor1];
            _firstActorButton.hidden = NO;
            [self.view bringSubviewToFront:_firstActorButton];
            [self.view bringSubviewToFront:_firstActorLabel];
            _thatMovieWithButton.hidden = NO;
            break;
        }
        case 2:
        {
            [[TMWActorContainer actorContainer] removeActorObject:actor2];
            _secondActorButton.hidden = NO;
            [self.view bringSubviewToFront:_secondActorButton];
            [self.view bringSubviewToFront:_secondActorLabel];
            _andButton.hidden = NO;
            break;
        }
    }
    // // Only hide the continue button if there are not actors
    if ([TMWActorContainer actorContainer].allActorObjects.count == 0)
    {
        _andButton.hidden = YES;
        // Reset the view back to the default load view
    }
}

- (void)loadImageConfiguration
{
    
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbConfiguration withParameters:nil andResponseBlock:^(id response, NSError *error) {
        
        if (!error) {
            [TMWActorContainer actorContainer].backdropSizes = response[@"images"][@"logo_sizes"];
            [TMWActorContainer actorContainer].imagesBaseURLString = [response[@"images"][@"base_url"] stringByAppendingString:[TMWActorContainer actorContainer].backdropSizes[1]];
        }
        else {
            [errorAlertView show];
        }
    }];
}

- (void)refreshActorResponseWithJLTMDBcall:(NSDictionary *)call
{
    NSString *JLTMDBCall = call[@"JLTMDBCall"];
    NSDictionary *parameters = call[@"parameters"];
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[JLTMDbClient sharedAPIInstance] GET:JLTMDBCall withParameters:parameters andResponseBlock:^(id response, NSError *error) {
        if (!error) {
            searchResults = [[TMWActorSearchResults alloc] initActorSearchResultsWithResults:response[@"results"]];
            //[[self.searchBarController searchResultsTableView] reloadData];
                //dispatch_async(dispatch_get_main_queue(),^{
                    [[self.searchBarController searchResultsTableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                //});
        }
        else {
            [errorAlertView show];
        }
    }];
}

- (void)setLabel:(UILabel *)textView
      withString:(NSString *)string
  inBoundsOfView:(UIView *)view
{
    textView.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:ACTOR_FONT_SIZE];
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    UIFont *textFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:ACTOR_FONT_SIZE];
    
    NSDictionary *attributes = @{NSFontAttributeName:textFont, NSParagraphStyleAttributeName: textStyle};
    CGRect bound = [string boundingRectWithSize:CGSizeMake(view.bounds.size.width-20, view.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    textView.numberOfLines = 4;
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

#pragma mark UIScrollView methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int x = abs(floor(scrollView.contentOffset.x*moviesSlideString.length*2/scrollOffset));
    if (scrollView == _firstActorScrollView) {
        _firstActorDeleteLabel.text = [deleteSlideString substringToIndex:(MIN(x, (int)deleteSlideString.length))];
        if (-1 * scrollView.contentOffset.x > abs(scrollOffset/2)) {
            _firstActorActionView.backgroundColor = [UIColor redColor];
        }
        else {
            _firstActorActionView.backgroundColor = [UIColor grayColor];
        }
    }
    
    if (scrollView == _secondActorScrollView) {
        _secondActorDeleteLabel.text = [deleteSlideString substringToIndex:(MIN(x, (int)deleteSlideString.length))];
        if (-1 * scrollView.contentOffset.x > abs(scrollOffset/2)) {
            _secondActorActionView.backgroundColor = [UIColor redColor];
        }
        else {
            _secondActorActionView.backgroundColor = [UIColor grayColor];
        }
    }
    if (_firstActorScrollView.contentOffset.x > 0 || _secondActorScrollView.contentOffset.x > 0) {
        
        _secondActorScrollView.contentOffset = scrollView.contentOffset;
        _firstActorScrollView.contentOffset = scrollView.contentOffset;
        //int x = ceil(_firstActorScrollView.contentOffset.x*moviesSlideString.length*2/scrollOffset);
        _firstActorActionLabel.text = [moviesSlideString substringToIndex:(MIN(x, (int)moviesSlideString.length))];
        _secondActorActionLabel.text = [moviesSlideString substringToIndex:(MIN(x, (int)moviesSlideString.length))];

        if (_firstActorScrollView.contentOffset.x > abs(scrollOffset/2)
            || _secondActorScrollView.contentOffset.x > abs(scrollOffset/2)) {
            _firstActorActionView.backgroundColor = [UIColor goldColor];
            _secondActorActionView.backgroundColor = [UIColor goldColor];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (scrollView == _firstActorScrollView) {
        
        // Move the other actor back into its original position
        if (_secondActorScrollView.contentOffset.x != 0) {
            // Set the delete view frame depending on the actors chosen
            if (self.firstActorLabel.text && ![self.firstActorActionView isDescendantOfView:self.view]) {
                [self.view insertSubview:self.firstActorActionView atIndex:1];
                self.firstActorActionView.backgroundColor = [UIColor goldColor];
            }
            [self animateScrollViewBoundsChange:_secondActorScrollView];
        }
    }
    
    if (scrollView == _secondActorScrollView) {
        
        // Move the other actor back into its original position
        if (_firstActorScrollView.contentOffset.x != 0) {
            if (self.secondActorLabel.text && ![self.secondActorActionView isDescendantOfView:self.view]) {
                [self.view insertSubview:self.secondActorActionView atIndex:1];
                self.secondActorActionView.backgroundColor = [UIColor goldColor];
            }
            [self animateScrollViewBoundsChange:_firstActorScrollView];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView == _firstActorScrollView || scrollView == _secondActorScrollView) {
        if (scrollView.contentOffset.x > scrollOffset/2) {

            // Show the Movies View
            TMWMoviesCollectionViewController *moviesViewController = [[TMWMoviesCollectionViewController alloc] init];
            [self.navigationController pushViewController:moviesViewController animated:YES];
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    }
    
    if (scrollView == _firstActorScrollView) {
        if (-1 * scrollView.contentOffset.x > abs(scrollOffset/2)) {
            tappedActor = 1;
            [self removeActor];
            _firstActorButton.imageView.image = nil;
            _firstActorButton.hidden = YES;
            _firstActorLabel.text = nil;
            //scrollView.contentOffset = CGPointMake(scrollOffset, 0);
            [_firstActorActionView removeFromSuperview];
            [self.view bringSubviewToFront:_thatMovieWithButton];
        }
    }
    
    if (scrollView == _secondActorScrollView) {
        if (-1 * scrollView.contentOffset.x > abs(scrollOffset/2)) {
            tappedActor = 2;
            [self removeActor];
            _secondActorButton.imageView.image = nil;
            _secondActorButton.hidden = YES;
            _secondActorLabel.text = nil;
            //scrollView.contentOffset = CGPointMake(scrollOffset, 0);
            [_secondActorActionView removeFromSuperview];
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

    // Delays on making the actor API calls
    if([searchText length] != 0) {
        float delay = 0.6;
        
        if (searchText.length > 3) {
            delay = 0.9;
        }
        
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
}


#pragma mark UISearchDisplayController methods

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
        
        // Set the line separator left offset to start after the image
        [_searchBarController.searchResultsTableView setSeparatorInset:UIEdgeInsetsMake(0, IMAGE_SIZE+IMAGE_TEXT_OFFSET, 0, 0)];
    }
    
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
        
        // Get the image from the URL and set it
        [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]] placeholderImage:[UIImage imageNamed:@"black"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
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
            NSLog(@"Request failed with error: %@", error);
        }];
        
        // Hide the network activity icon
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    else {
        UIImage *defaultImage = [UIImage imageByDrawingInitialsOnImage:[UIImage imageNamed:@"InitialsBackgroundLowRes.png"] withInitials:[searchResults.names objectAtIndex:indexPath.row] withFontSize:16];
        [cell.imageView setImage:defaultImage];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchDisplayController setActive:NO animated:NO];
    
    TMWActor *chosenActor = [[TMWActor alloc] initWithActor:[searchResults.results objectAtIndex:indexPath.row]];
    
    // Remove an actor if one was chosen
    [self removeActor];
    
    // Add the chosen actor to the array of chosen actors
    [[TMWActorContainer actorContainer] addActorObject:chosenActor];
    
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
        _andButton.hidden = YES;
        actor2 = chosenActor;
    }
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

    // If NSString, fetch the image, else use the generated UIImage
    if ([actor.hiResImageURLEnding isKindOfClass:[NSString class]]) {
        
        NSString *urlstring = [[[TMWActorContainer actorContainer].imagesBaseURLString stringByReplacingOccurrencesOfString:[TMWActorContainer actorContainer].backdropSizes[1] withString:[TMWActorContainer actorContainer].backdropSizes[5]] stringByAppendingString:actor.hiResImageURLEnding];
        
        __weak typeof(actorImage) weakActorImage = actorImage;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]];
        [actorImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"black"] success:^(NSURLRequest *req, NSHTTPURLResponse *response, UIImage *image) {
            
            // Set the image
            weakActorImage.image = image;
            
            // Set the image to the correct context
            UIGraphicsBeginImageContextWithOptions(weakActorImage.bounds.size, weakActorImage.opaque, 0.0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [weakActorImage.layer renderInContext:context];
            UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // Darken the image
            UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, weakActorImage.frame.size.width, weakActorImage.frame.size.height)];
            [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
            NSArray *viewsToRemove = [weakActorImage subviews];
            for (UIView *v in viewsToRemove) [v removeFromSuperview];
            [button addSubview:overlay];
            
            [button setBackgroundImage:screenShot forState:UIControlStateNormal];
            [weakActorImage removeFromSuperview];
            
            // Set the image label properties to center it in the cell
            [self setLabel:label withString:actor.name inBoundsOfView:button];
            label.hidden = NO;
            
            self.firstActorActionView.backgroundColor = [UIColor goldColor];
            self.secondActorActionView.backgroundColor = [UIColor goldColor];
            // Set the delete view frame depending on the actors chosen
            if (self.firstActorLabel.text && ![self.firstActorActionView isDescendantOfView:self.view]) {
                [self.view insertSubview:self.firstActorActionView atIndex:1];
            }
            if (self.secondActorLabel.text && ![self.secondActorActionView isDescendantOfView:self.view]) {
                [self.view insertSubview:self.secondActorActionView atIndex:1];
            }
            self.pushBehavior.pushDirection = CGVectorMake(-35.0f, 0.0f);
            self.pushBehavior.active = YES;
            
            
        } failure:^(NSURLRequest *failreq, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Failed with error: %@", error);
        }];
    }
    else {
        UIImage *defaultImage = [UIImage imageByDrawingInitialsOnImage:[UIImage imageNamed:@"InitialsBackgroundHiRes.png"] withInitials:actor.name withFontSize:48];
        [actorImage setImage:defaultImage];
        // Get the actor circle initials image with layer and set it to the button background
        UIGraphicsBeginImageContextWithOptions(actorImage.bounds.size, actorImage.opaque, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [actorImage.layer renderInContext:context];
        UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Darken the image
        UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, actorImage.frame.size.width, actorImage.frame.size.height)];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        NSArray *viewsToRemove = [actorImage subviews];
        for (UIView *v in viewsToRemove) [v removeFromSuperview];
        [button addSubview:overlay];
        
        [button setBackgroundImage:screenShot forState:UIControlStateNormal];
        [actorImage removeFromSuperview];
        
        // Set the image label properties to center it in the cell
        [self setLabel:label withString:actor.name inBoundsOfView:button];
        label.hidden = NO;
        
    }
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
- (void) keyboardWillHide
{
    UITableView *tableView = [[self searchDisplayController] searchResultsTableView];
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}


#pragma mark UIButton methods

-(IBAction)buttonPressed:(id)sender
{
    
    UIButton *button = (UIButton *)sender;
    
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
            
        case 3: // Continue button
        {
            // Show the Movies View if the continue button is pressed
            TMWMoviesCollectionViewController *moviesViewController = [[TMWMoviesCollectionViewController alloc] init];
            [self.navigationController pushViewController:moviesViewController animated:YES];
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            
            break;
        }
    }
}


@end
