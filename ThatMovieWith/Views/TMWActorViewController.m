//
//  TMWViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/15/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>
#import <FlatUIKit.h>

#import "TMWActorViewController.h"
#import "TMWMoviesViewController.h"
#import "TMWActor.h"
#import "TMWActorSearchResults.h"
#import "TMWActorContainer.h"
#import "TMWCustomActorCellTableViewCell.h" 

#import "CALayer+circleLayer.h" // Circle layer over actor
#import "UIImage+DrawInitialsOnImage.h" // Actor's without images
#import "UIImage+ImageEffects.h" // For the darkened blur effect
#import "UIColor+customColors.h"

#import <QuartzCore/QuartzCore.h>

@interface TMWActorViewController () {
    // Gesture recgonizers for dragging the actor images around
    UIPanGestureRecognizer *firstPanGesture;
    UIPanGestureRecognizer *secondPanGesture;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;
@property (strong, nonatomic) IBOutlet UIImageView *firstActorImage;
@property (strong, nonatomic) IBOutlet UIImageView *secondActorImage;
@property (strong, nonatomic) IBOutlet UIButton *firstActorButton;
@property (strong, nonatomic) IBOutlet UIButton *secondActorButton;
@property (strong, nonatomic) IBOutlet FUIButton *continueButton;
@property (strong, nonatomic) IBOutlet UILabel *thatMovieWithLabel;
@property (strong, nonatomic) IBOutlet UILabel *andLabel;
@property (strong, nonatomic) IBOutlet UIImageView *deleteImage;
@property (strong, nonatomic) IBOutlet UIView *deleteDropShadow;
@property (strong, nonatomic) IBOutlet UILabel *deleteLabel;
@property (strong, nonatomic) IBOutlet UIView *deleteGradientView;

// Animation stuff
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;
@property (strong, nonatomic) UISnapBehavior *snapBehavior;
@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;

@property (strong, nonatomic) UIImageView *blurImageView;
@property (strong, nonatomic) UIImageView *curtainView;

@end

@implementation TMWActorViewController

static const NSUInteger ALPHA_FULL = 1;
static const NSUInteger TABLE_HEIGHT = 66;
static const double ALPHA_EMPTY = 0.0;
static const double FADE_DURATION = 0.5;

TMWActorSearchResults *searchResults;
TMWActor *actor1;
TMWActor *actor2;
int tappedActor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

-(void)viewWillAppear:(BOOL)animated
{
    // Hide the navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Calls perferredStatusBarStyle
    [self setNeedsStatusBarAppearanceUpdate];

    // Make the keyboard black
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
    // Make the search bar text white
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor goldColor]];
    
    // Custom Fonts
    UIFont* broadwayFont = [UIFont fontWithName:@"Broadway" size:30];
    _thatMovieWithLabel.font = broadwayFont;
    _andLabel.font = broadwayFont;
    
    _curtainView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"curtains.jpg"]];
    
    _curtainView.frame = self.view.frame;
    UIImage *blurImage = [_curtainView.image applyDarkCurtainEffect];
    _curtainView.image = blurImage;
    [self.view insertSubview:_curtainView atIndex:0];
    
    
    //[self.view insertSubview:_curtainView atIndex:0];
    
    
    _thatMovieWithLabel.textColor = [UIColor goldColor];
    _andLabel.textColor = [UIColor goldColor];

    // Tag the actor buttons so they can be identified when pressed
    _firstActorButton.tag = 1;
    _secondActorButton.tag = 2;

    // Tag the continue button
    _continueButton.tag = 3;
    
    // Hide the "and" and second actor
    _andLabel.hidden = YES;
    _secondActorButton.hidden = YES;
    
    // Make the buttons glow
    _firstActorButton.showsTouchWhenHighlighted = YES;
    _secondActorButton.showsTouchWhenHighlighted = YES;
    
    // Setup for dragging the actors around
    firstPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    secondPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_firstActorButton addGestureRecognizer:firstPanGesture];
    [_secondActorButton addGestureRecognizer:secondPanGesture];
    firstPanGesture.enabled = NO;
    secondPanGesture.enabled = NO;
    
    
    // Add the gradient to the delete gradient view
    _deleteGradientView.backgroundColor = [UIColor clearColor];
    UIColor *colorOne = [UIColor clearColor];
    UIColor *colorTwo = [UIColor colorWithRed:(255/255.0)  green:(255/255.0)  blue:(255/255.0)  alpha:0.3];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.8];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.frame = self.view.bounds;
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    [_deleteGradientView.layer insertSublayer:headerLayer atIndex:0];
    
    // Setup the image and dropshadow for the delete icon
    [CALayer circleLayer:_deleteImage.layer];
    [_deleteDropShadow addSubview:_deleteImage];
    _deleteDropShadow.clipsToBounds = NO;

    _deleteDropShadow.layer.cornerRadius = _deleteDropShadow.frame.size.height/2;
    _deleteDropShadow.layer.shadowColor = [[UIColor whiteColor] CGColor];
    _deleteDropShadow.layer.shadowOpacity = 1.0;
    _deleteDropShadow.layer.shadowRadius = 5.0;
    _deleteDropShadow.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    // Custom continue button
    _continueButton.buttonColor = [UIColor goldColor];
    _continueButton.cornerRadius = 6.0f;
    _continueButton.titleLabel.font = [UIFont fontWithName:@"Broadway" size:20];
    [_continueButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // Get the base TMDB API URL string
    [self loadImageConfiguration];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
           [_firstActorButton setBackgroundImage:[UIImage imageNamed:@"addActor"] forState:UIControlStateNormal];
           [self.view bringSubviewToFront:_firstActorButton];
           firstPanGesture.enabled = NO;
           break;
       }
       case 2:
       {
           [[TMWActorContainer actorContainer] removeActorObject:actor2];
           _secondActorButton.hidden = NO;
           [_secondActorButton setBackgroundImage:[UIImage imageNamed:@"addActor"] forState:UIControlStateNormal];
           [self.view bringSubviewToFront:_secondActorButton];
           secondPanGesture.enabled = NO;
           break;
       }
   }
   // // Only hide the continue button if there are not actors
   if ([TMWActorContainer actorContainer].allActorObjects.count == 0)
   {
       // Reset the view back to the default load view
       [_firstActorButton setBackgroundImage:[UIImage imageNamed:@"addActor"] forState:UIControlStateNormal];
       secondPanGesture.enabled = NO;
       _continueButton.hidden = YES;
       _secondActorButton.hidden = YES;
       _andLabel.hidden = YES;
   }
}

- (void) loadImageConfiguration
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

- (void) refreshActorResponseWithJLTMDBcall:(NSDictionary *)call
{
    NSString *JLTMDBCall = call[@"JLTMDBCall"];
    NSDictionary *parameters = call[@"parameters"];
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[JLTMDbClient sharedAPIInstance] GET:JLTMDBCall withParameters:parameters andResponseBlock:^(id response, NSError *error) {
        // Turn off the network activity in the status bar
        dispatch_async(dispatch_get_main_queue(),^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        if (!error) {
            searchResults = [[TMWActorSearchResults alloc] initActorSearchResultsWithResults:response[@"results"]];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [[self.searchBarController searchResultsTableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            });
        }
        else {
            [errorAlertView show];
        }
    }];
}


-(void)showImage:(UIView*)image
{
    // Slowly make the image appear in animateWithDuration seconds
    image.hidden = YES;
    image.alpha = 0.0f;
    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        image.alpha = 1.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        image.hidden = NO;
    }];
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

#pragma mark UISearchBar methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // Delays on making the actor API calls
    if([searchText length] != 0) {
        float delay = 0.6;
        
        if (searchText.length > 3) {
            delay = 0.3;
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
        
        // Get the image from the URL and set it
        [cell.imageView setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:[UIImage imageNamed:@"Clear.png"]];
        
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
             ImageVisibility:self.firstActorImage
              withButton:_firstActorButton
                 atIndexPath:indexPath];
        
        // Enable dragging the actor around
        firstPanGesture.enabled = YES;
        
        // Show the second actor information
        actor1 = chosenActor;
        _andLabel.hidden = NO;
        _secondActorButton.hidden = NO;
    }
    else
    {
        // The second actor is the default selection for being replaced.
        [self configureActor:chosenActor
             ImageVisibility:self.secondActorImage
               withButton:_secondActorButton
                 atIndexPath:indexPath];
        
        // Enable dragging the actor around
        secondPanGesture.enabled = YES;
        _secondActorButton.hidden = NO;
        actor2 = chosenActor;
    }

    _continueButton.hidden = NO; 
}

// Wobble animation when adding an actor
- (CAAnimation*)getShakeAnimation
{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CGFloat wobbleAngle = 0.09f;
    
    NSValue* valLeft = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(wobbleAngle, 0.0f, 0.0f, 1.0f)];
    NSValue* valRight = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-wobbleAngle, 0.0f, 0.0f, 1.0f)];
    animation.values = [NSArray arrayWithObjects:valLeft, valRight, nil];
    
    animation.autoreverses = YES;
    animation.duration = 0.09;
    animation.repeatCount = 4;
    
    return animation;
}

// Set the actor image and all of it's necessary properties
- (void)configureActor:(TMWActor *)actor
       ImageVisibility:(UIImageView *)actorImage
            withButton:(UIButton *)button
           atIndexPath:(NSIndexPath *)indexPath
{
    // Make the image a circle
    [CALayer circleLayer:actorImage.layer];
    actorImage.contentMode = UIViewContentModeScaleAspectFill;
    actorImage.layer.cornerRadius = actorImage.frame.size.height/2;
    actorImage.layer.masksToBounds = YES;

    // Add a drop shadow
    [button addSubview:actorImage];
    actorImage.frame = button.bounds;
    button.clipsToBounds = NO;
    
    // If NSString, fetch the image, else use the generated UIImage
    if ([actor.hiResImageURLEnding isKindOfClass:[NSString class]]) {
        
        NSString *urlstring = [[[TMWActorContainer actorContainer].imagesBaseURLString stringByReplacingOccurrencesOfString:[TMWActorContainer actorContainer].backdropSizes[1] withString:[TMWActorContainer actorContainer].backdropSizes[4]] stringByAppendingString:actor.hiResImageURLEnding];
        
        __weak typeof(actorImage) weakActorImage = actorImage;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]];
        [actorImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"Clear.png"] success:^(NSURLRequest *req, NSHTTPURLResponse *response, UIImage *image) {
            
            // Set the image
            weakActorImage.image = image;
            // Get the actor circle image with layer and set it to the button background
            UIGraphicsBeginImageContextWithOptions(weakActorImage.bounds.size, weakActorImage.opaque, 0.0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [weakActorImage.layer renderInContext:context];
            UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [button setBackgroundImage:screenShot forState:UIControlStateNormal];
            [weakActorImage removeFromSuperview];
            
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
        [button setBackgroundImage:screenShot forState:UIControlStateNormal];
        [actorImage removeFromSuperview];
        
    }
    [self showImage:button];

    button.userInteractionEnabled = YES;
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    [button.layer addAnimation:[self getShakeAnimation] forKey:@"wiggle"];
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

// For showing the
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
            TMWMoviesViewController *moviesViewController = [[TMWMoviesViewController alloc] init];
            [self.navigationController pushViewController:moviesViewController animated:YES];
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            
            break;
        }
    }
}

#pragma mark UIPanGestureRecognizer Methods

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    static UIAttachmentBehavior *attachment;
    static CGPoint               startCenter;

    // variables for calculating angular velocity

    static CFAbsoluteTime        lastTime;
    static CGFloat               lastAngle;
    static CGFloat               angularVelocity;
    
    [self.view bringSubviewToFront:gesture.view];

    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        
        [_animator removeAllBehaviors];
        
        // Fade out/in the necessary images and text
        [self startGestureFade:gesture];

        startCenter = gesture.view.center;

        // calculate the center offset and anchor point

        CGPoint pointWithinAnimatedView = [gesture locationInView:gesture.view];

        UIOffset offset = UIOffsetMake(pointWithinAnimatedView.x - gesture.view.bounds.size.width / 2.0,
                                       pointWithinAnimatedView.y - gesture.view.bounds.size.height / 2.0);

        CGPoint anchor = [gesture locationInView:gesture.view.superview];

        // create attachment behavior

        attachment = [[UIAttachmentBehavior alloc] initWithItem:gesture.view
                                               offsetFromCenter:offset
                                               attachedToAnchor:anchor];

        // code to calculate angular velocity (seems curious that I have to calculate this myself, but I can if I have to)

        lastTime = CFAbsoluteTimeGetCurrent();
        lastAngle = [self angleOfView:gesture.view];

        attachment.action = ^{
            CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
            CGFloat angle = [self angleOfView:gesture.view];
            if (time > lastTime) {
                angularVelocity = (angle - lastAngle) / (time - lastTime);
                lastTime = time;
                lastAngle = angle;
            }
        };

        // add attachment behavior

        [_animator addBehavior:attachment];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        // as user makes gesture, update attachment behavior's anchor point, achieving drag 'n' rotate

        CGPoint anchor = [gesture locationInView:gesture.view.superview];
        attachment.anchorPoint = anchor;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [_animator removeAllBehaviors];

        // When the view intersects with the delete image, go ahead and remove it
        if (CGRectIntersectsRect(_deleteDropShadow.frame, gesture.view.frame)) {
            // Fade out/in the necessary images and text
            [self endGestureFade:gesture];
            
            [_animator removeAllBehaviors];
            for (UIView *view in gesture.view.subviews) {
                view.hidden = YES;
            }
            gesture.view.hidden = YES;
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
            [_animator addBehavior:snap];
            tappedActor = (int)gesture.view.tag;
            [self removeActor];
        }

        // if we aren't dragging it down, just snap it back and quit
        CGPoint velocity = [gesture velocityInView:self.view];
        CGFloat velocityMagnitude = hypot(velocity.x, velocity.y);
        CGFloat triggerVelocity = 800;
        if (velocityMagnitude<triggerVelocity) {
            // Fade out/in the necessary images and text
            [self endGestureFade:gesture];
            
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
            [_animator addBehavior:snap];

            return;
        }

        // otherwise, create UIDynamicItemBehavior that carries on animation from where the gesture left off (notably linear and angular velocity)

        UIDynamicItemBehavior *dynamic = [[UIDynamicItemBehavior alloc] initWithItems:@[gesture.view]];
        [dynamic addLinearVelocity:velocity forItem:gesture.view];
        [dynamic addAngularVelocity:angularVelocity forItem:gesture.view];
        [dynamic setAngularResistance:2];

        // when the view no longer intersects with its superview, go ahead and remove it
        dynamic.action = ^{
            if (!CGRectIntersectsRect(gesture.view.superview.bounds, gesture.view.frame)) {
                // Fade out/in the necessary images and text
                [self endGestureFade:gesture];
                
                [self.animator removeAllBehaviors];
                for (UIView *view in gesture.view.subviews) {
                    view.hidden = YES;
                }
                gesture.view.hidden = YES;
                UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
                [self.animator addBehavior:snap];
                tappedActor = (int)gesture.view.tag;
                [self removeActor];
            }
        };
        
        [_animator addBehavior:dynamic];

        // add a little gravity so it accelerates off the screen (in case user gesture was slow)

        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[gesture.view]];
        gravity.magnitude = 0.1;
        [_animator addBehavior:gravity];
        
    }
}

- (CGFloat)angleOfView:(UIView *)view
{
    return atan2(view.transform.b, view.transform.a);
}

// Fades the necessary views when an actor is dragged around
- (void)startGestureFade:(UIGestureRecognizer *)gesture
{
    // Add the drop shadow effect to the view
    gesture.view.layer.cornerRadius = gesture.view.frame.size.height/2;
    gesture.view.layer.shadowColor = [[UIColor goldColor] CGColor];
    gesture.view.layer.shadowOpacity = 1.0;
    gesture.view.layer.shadowRadius = 5.0;
    gesture.view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    [gesture.view setNeedsDisplay];
    
    [_deleteDropShadow setNeedsDisplay];
    
    _deleteImage.hidden = NO;
    [self slideUpAnimation:_deleteGradientView];
    [self slideUpAnimation:_deleteDropShadow];
}

// Fades the necessary views when an actor is dragged around
- (void)endGestureFade:(UIGestureRecognizer *)gesture
{
    // Remove the drop shadow effect from the actor image
    gesture.view.layer.shadowOpacity = 0.0;
    
    [self fadeAnimation:self.deleteLabel];
    [self slideDownAnimation:_deleteGradientView];
    [self slideDownAnimation:_deleteDropShadow];
}

- (void)fadeAnimation:(UIView *)view
{
    view.alpha = ALPHA_FULL;
    [UIView animateWithDuration:FADE_DURATION delay:0.0 options:0 animations:^{
        view.alpha = ALPHA_EMPTY;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
    }];
    
}

- (void)appearAnimation:(UIView *)view
{
    view.alpha = ALPHA_EMPTY;
    [UIView animateWithDuration:FADE_DURATION delay:0.0 options:0 animations:^{
        view.alpha = ALPHA_FULL;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
    }];
}

- (void)slideUpAnimation:(UIView *)view
{
    view.center = CGPointMake(view.center.x, view.center.y + 100.0);
    view.alpha = 1.0;
    view.hidden = NO;
    [UIView animateWithDuration:FADE_DURATION delay:0.0 options:0
                     animations:^{
                         view.center = CGPointMake(view.center.x, view.center.y - 100.0);
                     } completion:^(BOOL finished) {
                         [self showImage:self.deleteLabel];
                     }];
}

- (void)slideDownAnimation:(UIView *)view
{
    [UIView animateWithDuration:FADE_DURATION delay:0.0 options:0
                     animations:^{
                         view.center = CGPointMake(view.center.x, view.center.y + 100.0);
                     } completion:^(BOOL finished) {
                         // Move the view back
                         view.center = CGPointMake(view.center.x, view.center.y - 100.0);
                         view.alpha = 0.0;
                         view.hidden = YES;
                     }];
}

@end
