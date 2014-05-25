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

@interface TMWMainViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;
@property (strong, nonatomic) IBOutlet UIButton *firstActorButton;
@property (strong, nonatomic) IBOutlet UIButton *secondActorButton;

@property (strong, nonatomic) UILabel *firstActorLabel;
@property (strong, nonatomic) UILabel *secondActorLabel;
@property (strong, nonatomic) UIImageView *blurImageView;
@property (strong, nonatomic) UIImageView *curtainView;

@end

@implementation TMWMainViewController

static const NSUInteger TABLE_HEIGHT = 66;
static const NSUInteger ACTOR_FONT_SIZE = 42;

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
    
    // Make the keyboard black
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
    // Make the search bar text white
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor goldColor]];
    
//    // Custom Fonts
//    UIFont* broadwayFont = [UIFont fontWithName:@"Broadway" size:30];
//    _thatMovieWithLabel.font = broadwayFont;
//    _andLabel.font = broadwayFont;
//    
    _curtainView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"curtain.jpg"]];
    
    UIImage *blurImage = [_curtainView.image applyVeryDarkCurtainEffect];
    _curtainView.image = blurImage;
    
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
//
//    
    [self.view insertSubview:_curtainView atIndex:0];
//
//    // Set the text color and dropshadows
//    _thatMovieWithLabel.textColor = [UIColor goldColor];
//    [CALayer dropShadowLayer:_thatMovieWithLabel.layer];
//    
//    _andLabel.textColor = [UIColor goldColor];
//    [CALayer dropShadowLayer:_andLabel.layer];
//    
//    // Custom dropshadows for the buttons
//    [CALayer dropShadowLayer:_firstActorButton.layer];
//    [CALayer dropShadowLayer:_secondActorButton.layer];
//    [CALayer dropShadowLayer:_continueButton.layer];
    
    _secondActorButton.hidden = YES;
    
    _firstActorButton.frame = CGRectMake(self.view.bounds.origin.x , self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height/2);
    _secondActorButton.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height/2);
    
    
    _firstActorLabel = [UILabel new];
    _firstActorLabel.hidden = NO;
    _firstActorLabel.textColor = [UIColor whiteColor];
    _firstActorLabel.textAlignment = NSTextAlignmentCenter;
    _firstActorLabel.backgroundColor = [UIColor clearColor];
    _firstActorLabel.frame = _firstActorButton.frame;
    [self.view insertSubview:_firstActorLabel atIndex:0];
    
    _secondActorLabel = [UILabel new];
    _secondActorLabel.hidden = NO;
    _secondActorLabel.textColor = [UIColor whiteColor];
    _secondActorLabel.textAlignment = NSTextAlignmentCenter;
    _secondActorLabel.backgroundColor = [UIColor clearColor];
    _secondActorLabel.frame = _secondActorButton.frame;
    [self.view insertSubview:_secondActorLabel atIndex:0];
    
    
    // Tag the actor buttons so they can be identified when pressed
    _firstActorButton.tag = 1;
    _secondActorButton.tag = 2;
    
    // Hide the "and" and second actor
//    _andLabel.hidden = YES;



    
    
    // Setup for dragging the actors around
//    firstPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    secondPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    [_firstActorButton addGestureRecognizer:firstPanGesture];
//    [_secondActorButton addGestureRecognizer:secondPanGesture];
//    firstPanGesture.enabled = NO;
//    secondPanGesture.enabled = NO;
    
    // Move the delete label outside of the view
//    _deleteLabel.center = CGPointMake(_deleteLabel.center.x, _deleteLabel.center.y - POP_SLIDE_DISTANCE);
    
    
    // Add the gradient to the delete gradient view
//    _deleteGradientView.backgroundColor = [UIColor clearColor];
//    UIColor *colorOne = [UIColor colorWithRed:(0/255.0)  green:(0/255.0)  blue:(0/255.0)  alpha:0.6];
//    UIColor *colorTwo = [UIColor clearColor];
//    
//    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
//    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
//    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
//    
//    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
//    
//    CAGradientLayer *headerLayer = [CAGradientLayer layer];
//    headerLayer.frame = _deleteGradientView.frame;
//    headerLayer.colors = colors;
//    headerLayer.locations = locations;
//    [_deleteGradientView.layer insertSublayer:headerLayer atIndex:0];
    
    // Custom continue button
//    _continueButton.buttonColor = [UIColor goldColor];
//    _continueButton.cornerRadius = 6.0f;
//    _continueButton.titleLabel.font = [UIFont fontWithName:@"Broadway" size:20];
//    [_continueButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
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
            [_firstActorButton setBackgroundImage:[UIImage imageNamed:@"addActor"] forState:UIControlStateNormal];
            [self.view bringSubviewToFront:_firstActorButton];
            [self.view bringSubviewToFront:_firstActorLabel];
            //firstPanGesture.enabled = NO;
            break;
        }
        case 2:
        {
            [[TMWActorContainer actorContainer] removeActorObject:actor2];
            _secondActorButton.hidden = NO;
            [_secondActorButton setBackgroundImage:[UIImage imageNamed:@"addActor"] forState:UIControlStateNormal];
            [self.view bringSubviewToFront:_secondActorButton];
            [self.view bringSubviewToFront:_secondActorLabel];
            //secondPanGesture.enabled = NO;
            break;
        }
    }
    // // Only hide the continue button if there are not actors
    if ([TMWActorContainer actorContainer].allActorObjects.count == 0)
    {
        // Reset the view back to the default load view
        [_firstActorButton setBackgroundImage:[UIImage imageNamed:@"addActor"] forState:UIControlStateNormal];
//        secondPanGesture.enabled = NO;
//        _continueButton.hidden = YES;
//        _secondActorButton.hidden = YES;
//        _andLabel.hidden = YES;
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
    
    [[JLTMDbClient sharedAPIInstance] GET:JLTMDBCall withParameters:parameters andResponseBlock:^(id response, NSError *error) {
        
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
    //cell.textView.frame = textRect;
    textView.text = string;
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
        
        // Enable dragging the actor around
        //firstPanGesture.enabled = YES;
        
        // Show the second actor information
        actor1 = chosenActor;
        //_andLabel.hidden = NO;
        _secondActorButton.hidden = NO;
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
        actor2 = chosenActor;
        // Show the Movies View if the continue button is pressed
        TMWMoviesCollectionViewController *moviesViewController = [[TMWMoviesCollectionViewController alloc] init];
        [self.navigationController pushViewController:moviesViewController animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
//
//    _continueButton.hidden = NO;
}

// Set the actor image and all of it's necessary properties
- (void)configureActor:(TMWActor *)actor
            withButton:(UIButton *)button
              andLabel:(UILabel *)label
           atIndexPath:(NSIndexPath *)indexPath
{
    // Make the image a circle
//    [CALayer circleLayer:actorImage.layer];
//    actorImage.contentMode = UIViewContentModeScaleAspectFill;
//    actorImage.layer.cornerRadius = actorImage.frame.size.height/2;
//    actorImage.layer.masksToBounds = YES;
    UIImageView *actorImage = [UIImageView new];
    actorImage.contentMode = UIViewContentModeScaleAspectFill;
    
    // Add a drop shadow
    [button addSubview:actorImage];
    actorImage.frame = button.bounds;
    button.clipsToBounds = NO;

    // If NSString, fetch the image, else use the generated UIImage
    if ([actor.hiResImageURLEnding isKindOfClass:[NSString class]]) {
        
        NSString *urlstring = [[[TMWActorContainer actorContainer].imagesBaseURLString stringByReplacingOccurrencesOfString:[TMWActorContainer actorContainer].backdropSizes[1] withString:[TMWActorContainer actorContainer].backdropSizes[6]] stringByAppendingString:actor.hiResImageURLEnding];
        
        __weak typeof(actorImage) weakActorImage = actorImage;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]];
        [actorImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"black"] success:^(NSURLRequest *req, NSHTTPURLResponse *response, UIImage *image) {
            
            // Set the image
            weakActorImage.image = image;
            // Get the actor circle image with layer and set it to the button background
            UIGraphicsBeginImageContextWithOptions(weakActorImage.bounds.size, weakActorImage.opaque, 0.0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [weakActorImage.layer renderInContext:context];
            UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // Darken the image
            UIImage *darkImage = [screenShot applyPosterEffect];
            
            [button setBackgroundImage:darkImage forState:UIControlStateNormal];
            [weakActorImage removeFromSuperview];
            
            POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
            anim.springSpeed = 15;
            anim.springBounciness = 22;
            anim.fromValue  = [NSValue valueWithCGSize:CGSizeMake(0.0f, 0.0f)];
            anim.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
            [button.layer pop_addAnimation:anim forKey:@"scaleAnimation"];
            
            // Set the image label properties to center it in the cell
            [self setLabel:label withString:actor.name inBoundsOfView:button];

            
            // [button.layer addAnimation:[self getShakeAnimation] forKey:@"wiggle"];
            
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
        
//        POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//        anim.springSpeed = POP_ACTOR_SPRING_SPEED;
//        anim.springBounciness = POP_ACTOR_SPRING_BOUNCINESS;
//        anim.fromValue  = [NSValue valueWithCGSize:CGSizeMake(0.0f, 0.0f)];
//        anim.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
//        [button.layer pop_addAnimation:anim forKey:@"scaleAnimation"];
        
    }
//    [self showImage:button];
//    
//    button.userInteractionEnabled = YES;
//    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
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
