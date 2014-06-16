//
//  TMWMainViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 5/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>
#import <FBShimmeringView.h>

#import "TMWActorViewController.h"
#import "TMWActor.h"
#import "TMWActorContainer.h"
#import "TMWContainerViewController.h"
#import "TMWActorSearchResults.h"
#import "TMWMoviesCollectionViewController.h"
#import "TMWCustomActorCellTableViewCell.h"
#import "TMWAPI.h"

#import "UIImage+ImageEffects.h"
#import "UIColor+customColors.h"
#import "UIImage+DrawOnImage.h"
#import "CALayer+circleLayer.h"

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

NSString *moviesSlideString = @"Show\nmovies";
NSString *deleteSlideString = @"Remove\nActor";

TMWActorSearchResults *searchResults;
TMWActor *actor1;
TMWActor *actor2;
int tappedActor;
bool hasSearched;
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
        NSLog(@"%f", self.view.frame.size.height);
        scrollOffset = (self.view.frame.size.width/2) - 55;
        _curtainView.frame = self.view.frame;
        _statusBarView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 20);
        
        frameX = self.view.frame.origin.x;
        frameY = self.view.frame.origin.y+20;
        frameW = self.view.frame.size.width;
        frameH = self.view.frame.size.height-20;
        
        _firstActorScrollView.frame = CGRectMake(self.view.frame.origin.x - scrollOffset, frameY, self.view.frame.size.width + scrollOffset, frameH/2);
        _firstActorScrollView.contentSize = CGRectMake(self.view.frame.origin.x, frameY, self.view.frame.size.width + (scrollOffset * 2.0), frameH/2).size;
        _firstActorScrollView.contentInset = UIEdgeInsetsMake(0, scrollOffset, 0, 0);
        _firstActorScrollView.pagingEnabled = YES;
        _firstActorScrollView.showsHorizontalScrollIndicator = NO;
        _firstActorScrollView.bounces = NO;
        _firstActorScrollView.delegate = self;
        
        _secondActorScrollView.frame = CGRectMake(self.view.frame.origin.x - scrollOffset, frameY + frameH/2, self.view.frame.size.width + scrollOffset, frameH/2);
        _secondActorScrollView.contentSize = CGRectMake(self.view.frame.origin.x, frameY, self.view.frame.size.width + (scrollOffset * 2.0), frameH/2).size;
        _secondActorScrollView.contentInset = UIEdgeInsetsMake(0, scrollOffset, 0, 0);
        _secondActorScrollView.pagingEnabled = YES;
        _secondActorScrollView.showsHorizontalScrollIndicator = NO;
        _secondActorScrollView.bounces = NO;
        _secondActorScrollView.delegate = self;
        
        // Buttons
        _firstActorButton.frame = CGRectMake(self.view.frame.origin.x + scrollOffset, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2);
        _secondActorButton.frame = CGRectMake(self.view.frame.origin.x + scrollOffset, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2);
        
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
        _firstActorActionView.frame = CGRectMake(frameX, frameY, frameW + scrollOffset, frameH/2);
        _firstActorActionView.backgroundColor = [UIColor grayColor];
        
        _secondActorActionView.frame = CGRectMake(frameX, frameY + frameH/2, frameW + scrollOffset, frameH/2);
        _secondActorActionView.backgroundColor = [UIColor grayColor];
        
        _firstActorActionLabel.frame = CGRectMake(self.view.frame.size.width - 100, frameY - 20, 100, frameH/2);
        _firstActorActionLabel.text = moviesSlideString;
        _firstActorActionLabel.numberOfLines = 2;
        _firstActorActionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:24];
        _firstActorActionLabel.textAlignment = NSTextAlignmentCenter;
        
        _secondActorActionLabel.frame = CGRectMake(self.view.frame.size.width - 100, frameY - 20, 100, frameH/2);
        _secondActorActionLabel.text = moviesSlideString;
        _secondActorActionLabel.numberOfLines = 2;
        _secondActorActionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:24];
        _secondActorActionLabel.textAlignment = NSTextAlignmentCenter;
        
        _firstActorDeleteLabel.frame = CGRectMake(5, frameY - 20, 100, frameH/2);
        _firstActorDeleteLabel.text = deleteSlideString;
        _firstActorDeleteLabel.numberOfLines = 2;
        _firstActorDeleteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:24];
        _firstActorDeleteLabel.textAlignment = NSTextAlignmentCenter;
        
        _secondActorDeleteLabel.frame = CGRectMake(5, frameY - 20, 100, frameH/2);
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
    _curtainView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red-blur.jpg"]];
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
    _statusBarView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    
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
    [UIView animateWithDuration:2.0
                          delay:0
                        options:0
                     animations:^(void) {
                         self.thatMovieWithButton.alpha = 1.0;
                     }
                     completion:nil];


    // Get the base TMDB API URL string
    [self loadImageConfiguration];
}

-(void)viewWillAppear:(BOOL)animated
{
    // Hide the navigation bar
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
            [[TMWActorContainer actorContainer] removeActorObject:actor1];
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
            [[TMWActorContainer actorContainer] removeActorObject:actor2];
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
        _thatMovieWithButton.frame = CGRectMake(frameX, frameY - 10, frameW, frameH/2);
        _thatMovieShimmeringView.frame = CGRectMake(frameX, frameY - 10, frameW, frameH/2);
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
    textView.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:ACTOR_FONT_SIZE];
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    UIFont *textFont = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:ACTOR_FONT_SIZE];
    
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
            _firstActorActionLabel.text = @"Common movies";
            
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
            _firstActorActionLabel.frame = CGRectMake(self.view.frame.size.width - 100, frameY - 20, 100, frameH/2);
            _secondActorActionLabel.frame = CGRectMake(self.view.frame.size.width - 100, frameY - 20, 100, frameH/2);
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
            self.thatMovieWithButton.alpha = 0.0;
            [UIView animateWithDuration:1.0
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
                [UIView animateWithDuration:1.0
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
            self.andButton.alpha = 0.0;
            [UIView animateWithDuration:1.0
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
                 [UIView animateWithDuration:1.0
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
//                NZAlertView *alert = [[NZAlertView alloc] initWithStyle:NZAlertStyleError
//                                                                  title:@"Error Fetching Images"
//                                                                message:@"Could not get actor images from database"
//                                                               delegate:nil];
//                alert.alertDuration = 4.0;
//                
//                [alert setTextAlignment:NSTextAlignmentCenter];
//                
//                [alert show];
            }
            else {
                weakCell.imageView.image = image;
            }
            
            
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            // There are several ways to init, just look at the class header
//            NZAlertView *alert = [[NZAlertView alloc] initWithStyle:NZAlertStyleError
//                                                              title:@"Error Fetching Images"
//                                                            message:@"Could not get actor images from database"
//                                                           delegate:nil];
//            alert.alertDuration = 4.0;
//            
//            [alert setTextAlignment:NSTextAlignmentCenter];
//            
//            [alert show];
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
    
    // Add the chosen actor to the array of chosen actors
    [[TMWActorContainer actorContainer] addActorObject:chosenActor];
    
    // Remove an actor if one was chosen
    [self removeActor];
    
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
            self.pushBehavior.pushDirection = CGVectorMake(-35.0f, 0.0f);
            self.pushBehavior.active = YES;
            
            
        } failure:^(NSURLRequest *failreq, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Failed with error: %@", error);
        }];
    }
    else {
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
        self.pushBehavior.pushDirection = CGVectorMake(-35.0f, 0.0f);
        self.pushBehavior.active = YES;
        
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
