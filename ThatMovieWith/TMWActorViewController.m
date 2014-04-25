//
//  TMWViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/15/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>

#import "TMWActorViewController.h"
#import "TMWMoviesViewController.h"
#import "TMWActor.h"
#import "TMWActorSearchResults.h"
#import "TMWActorContainer.h"
#import "TMWCustomCellTableViewCell.h"
#import "TMWCustomAnimations.h"

#import "UIColor+customColors.h"
#import "CALayer+circleLayer.h"
#import "UIImage+DrawInitialsOnImage.h"

@interface TMWActorViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;
@property (strong, nonatomic) IBOutlet UILabel *firstActorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *firstActorImage;
@property (strong, nonatomic) IBOutlet UILabel *secondActorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *secondActorImage;
@property (strong, nonatomic) IBOutlet UIView *firstActorDropShadow;
@property (strong, nonatomic) IBOutlet UIView *secondActorDropShadow;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UIButton *backgroundButton;
@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *startSecondaryLabel;
@property (strong, nonatomic) IBOutlet UILabel *startThirdLabel;
@property (strong, nonatomic) IBOutlet UIImageView *startArrow;
@property (strong, nonatomic) IBOutlet UIImageView *deleteImage;
@property (strong, nonatomic) IBOutlet UIView *deleteDropShadow;
@property (strong, nonatomic) IBOutlet UILabel *deleteLabel;

// Animation stuff
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;
@property (strong, nonatomic) UISnapBehavior *snapBehavior;
@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;

@end

@implementation TMWActorViewController

TMWActorSearchResults *searchResults;
NSArray *backdropSizes;

#define ALPHA_FULL      1.0
#define ALPHA_EMPTY     0.0
#define FADE_DURATION   0.5
#define TABLE_HEIGHT    66

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
        
        
        [self showSearchHelp];
        
    }
    return self;
}

// Fade in the search instructions
-(void)showSearchHelp
{
    NSLog(@"Help!!!");
    self.startLabel.alpha = 0.0;
    self.startThirdLabel.alpha = 0.0;
    self.startArrow.alpha = 0.0;
    self.startArrow.hidden = NO;
    self.startLabel.hidden = NO;
    self.startThirdLabel.hidden = NO;
    [UIView animateWithDuration:1.5 delay:2.5 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        self.startLabel.alpha = 1.0;
        self.startArrow.alpha = 1.0;
        self.startSecondaryLabel.alpha = 0.0;
    } completion:nil];
    [UIView animateWithDuration:1.5 delay:4.5 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        self.startThirdLabel.alpha = 1.0;
    } completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Fade in the search instructions
    [self performSelector:@selector(showSearchHelp) withObject:self afterDelay:2.0];
    
    [self loadImageConfiguration];
}


// Remove the actor
- (void)removeActor:(int)actorNum
{
    switch (actorNum) {
        
        case 1:
        {
            NSArray *chosenCopy = [TMWActorContainer actorContainer].allActorObjects;
            for (TMWActor *actor in chosenCopy) {
                if ([actor.name isEqualToString:self.firstActorLabel.text]) {
                    [[TMWActorContainer actorContainer] removeActorObject:actor];
                    break;
                }
            }
            self.firstActorLabel.text = @"";
            break;
        }
        case 2:
        {
            NSArray *chosenCopy = [TMWActorContainer actorContainer].allActorObjects;
            for (TMWActor *actor in chosenCopy) {
                if ([actor.name isEqualToString:self.secondActorLabel.text]) {
                    [[TMWActorContainer actorContainer] removeActorObject:actor];
                    break;
                }
            }
            self.secondActorLabel.text = @"";
            break;
        }
    }
    // Only hide the continue button if there are not actors
    if ([TMWActorContainer actorContainer].allActorObjects.count == 0)
    {
        self.continueButton.hidden = YES;
        self.startLabel.hidden = NO;
        //self.startSecondaryLabel.hidden = NO;
        self.startThirdLabel.hidden = NO;
        [self.startArrow setImage: [UIImage imageNamed:@"arrow.png"]];
    }
}

-(void)showImage:(UIView*)image
{
    image.hidden = YES;
    image.alpha = 0.0f;
    // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        image.alpha = 1.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        image.hidden = NO;
    }];
}

#pragma mark UISearchBar methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
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

#pragma mark UITableView methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.startLabel.hidden = YES;
    self.startSecondaryLabel.hidden = YES;
    self.startThirdLabel.hidden = YES;
    [self.startArrow setImage:nil];
    
    [self.searchDisplayController setActive:NO animated:YES];
    
    // Remove the bottom (second) actor if both of the actors have been chosen
    if (![self.firstActorLabel.text isEqualToString:@""] && ![self.secondActorLabel.text isEqualToString:@""])
    {
        NSArray *chosenCopy = [TMWActorContainer actorContainer].allActorObjects;
        for (TMWActor *actor in chosenCopy)
        {
            if ([actor.name isEqualToString: self.secondActorLabel.text])
            {
                NSLog(@"Removing actor %@", actor.name);
                [[TMWActorContainer actorContainer] removeActorObject:actor];
                break;
            }
        }
    }
    TMWActor *chosenActor = [[TMWActor alloc] initWithActor:[searchResults.results objectAtIndex:indexPath.row]];

    // Add the chosen actor to the array of chosen actors
    [[TMWActorContainer actorContainer] addActorObject:chosenActor];
    
    if ([self.firstActorLabel.text isEqualToString:@""])
    {
        // The second actor is the default selection for being replaced.
        self.firstActorDropShadow.tag = 1;
        [self configureActor:chosenActor
             ImageVisibility:self.firstActorImage
              withDropShadow:self.firstActorDropShadow
                andTextLabel:self.firstActorLabel
                 atIndexPath:indexPath];
    }
    else
    {
        // The second actor is the default selection for being replaced.
        self.secondActorDropShadow.tag = 2;
        [self configureActor:chosenActor
             ImageVisibility:self.secondActorImage
               withDropShadow:self.secondActorDropShadow
                andTextLabel:self.secondActorLabel
                 atIndexPath:indexPath];
    }
    
    // One of the actors has been chosen
    if (![self.firstActorLabel.text isEqualToString:@""] || ![self.secondActorLabel.text isEqualToString:@""])
    {
        self.continueButton.tag = 3;
        self.backgroundButton.tag = 4;
        self.continueButton.hidden = NO;
        
        // Make the continue button animate
        //[self.continueButton.layer addAnimation:[TMWCustomAnimations buttonOpacityAnimation] forKey:@"opacity"];
    }

}


// Set the actor image and all of it's necessary properties
- (void)configureActor:(TMWActor *)actor
       ImageVisibility:(UIImageView *)actorImage
        withDropShadow:(UIView *)dropShadow
          andTextLabel:(UILabel *)textLabel
           atIndexPath:(NSIndexPath *)indexPath
{
    textLabel.hidden = NO;
    textLabel.alpha = 1.0;
    textLabel.text = actor.name;
    
    // Make the image a circle
    [CALayer circleLayer:actorImage.layer];
    actorImage.contentMode = UIViewContentModeScaleAspectFill;
    actorImage.layer.cornerRadius = actorImage.frame.size.height/2;
    actorImage.layer.masksToBounds = YES;
    

    [dropShadow addSubview:actorImage];
    actorImage.frame = CGRectMake(dropShadow.frame.origin.x-40, dropShadow.frame.origin.y-40, actorImage.frame.size.width, actorImage.frame.size.height);
    dropShadow.clipsToBounds = NO;
    
    // If NSString, fetch the image, else use the generated UIImage
    if ([actor.hiResImageURLEnding isKindOfClass:[NSString class]]) {
        
        NSString *urlstring = [[self.imagesBaseUrlString stringByReplacingOccurrencesOfString:backdropSizes[1] withString:backdropSizes[4]] stringByAppendingString:actor.hiResImageURLEnding];
        
        [actorImage setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:[UIImage imageNamed:@"Clear.png"]];
    }
    else {
        UIImage *defaultImage = [UIImage imageByDrawingInitialsOnImage:[UIImage imageNamed:@"InitialsBackgroundHiRes.png"] withInitials:actor.name withFontSize:48];
        [actorImage setImage:defaultImage];
    }
    [self showImage:actorImage];
    [self showImage:dropShadow];
    
    // Setup for dragging the image around
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [dropShadow addGestureRecognizer:panGesture];
    
    //Setup for tapping on the image
    UITapGestureRecognizer *longPressOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [dropShadow addGestureRecognizer:longPressOne];
    
    dropShadow.userInteractionEnabled = YES;
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    [self.view bringSubviewToFront:dropShadow];
}


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
    
    TMWCustomCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[TMWCustomCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                 reuseIdentifier:CellIdentifier];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        tableView.showsVerticalScrollIndicator = YES;
        [cell layoutSubviews];
    }
    cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height/2;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderWidth = 0;

    cell.textLabel.text = [searchResults.names objectAtIndex:indexPath.row];

    // If NSString, fetch the image, else use the generated UIImage
    if ([[searchResults.lowResImageEndingURLs objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        
        NSString *urlstring = [self.imagesBaseUrlString stringByAppendingString:[searchResults.lowResImageEndingURLs objectAtIndex:indexPath.row]];
        
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
        case 3: // Continue button
        {
            // Show the Movies View if the continue button is pressed
            if ([button tag] == 3) {
                
                TMWMoviesViewController *moviesViewController = [[TMWMoviesViewController alloc] init];
                [self.navigationController pushViewController:moviesViewController animated:YES];
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            }
            break;
        }
        case 4: // Background button
        {
            break; // flip the image back over
        }
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tap
{
    NSLog(@"%ld", (long)tap.view.tag);
    // Perform flipping here
}


#pragma mark Private Methods

- (void) loadImageConfiguration
{
    
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbConfiguration withParameters:nil andResponseBlock:^(id response, NSError *error) {

        if (!error) {
            backdropSizes = response[@"images"][@"logo_sizes"];
            self.imagesBaseUrlString = [response[@"images"][@"base_url"] stringByAppendingString:backdropSizes[1]];
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
        
        [self.animator removeAllBehaviors];
        
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

        [self.animator addBehavior:attachment];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        // as user makes gesture, update attachment behavior's anchor point, achieving drag 'n' rotate

        CGPoint anchor = [gesture locationInView:gesture.view.superview];
        attachment.anchorPoint = anchor;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        
        [self.animator removeAllBehaviors];

        // When the view intersects with the delete image, go ahead and remove it
        if (CGRectIntersectsRect(self.deleteDropShadow.frame, gesture.view.frame)) {
            // Fade out/in the necessary images and text
            [self endGestureFade:gesture];
            
            [self.animator removeAllBehaviors];
            for (UIView *view in gesture.view.subviews)
            {
                view.hidden = YES;
            }
            gesture.view.hidden = YES;
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
            [self.animator addBehavior:snap];
            [self removeActor:(int)gesture.view.tag];
        }

        // if we aren't dragging it down, just snap it back and quit
        CGPoint velocity = [gesture velocityInView:self.view];
        CGFloat velocityMagnitude = hypot(velocity.x, velocity.y);
        CGFloat triggerVelocity = 500;
        if (velocityMagnitude<triggerVelocity) {
            // Fade out/in the necessary images and text
            [self endGestureFade:gesture];
            
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
            [self.animator addBehavior:snap];

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
                for (UIView *view in gesture.view.subviews)
                {
                    view.hidden = YES;
                }
                gesture.view.hidden = YES;
                UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
                [self.animator addBehavior:snap];
                [self removeActor:(int)gesture.view.tag];
            }
        };
        
        [self.animator addBehavior:dynamic];

        // add a little gravity so it accelerates off the screen (in case user gesture was slow)

        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[gesture.view]];
        gravity.magnitude = 0.1;
        [self.animator addBehavior:gravity];
        
    }
}

- (CGFloat)angleOfView:(UIView *)view
{
    return atan2(view.transform.b, view.transform.a);
}

- (void)startGestureFade:(UIGestureRecognizer *)gesture
{
    // Add the drop shadow effect to the view
    gesture.view.layer.cornerRadius = gesture.view.frame.size.height/2;
    gesture.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    gesture.view.layer.shadowOpacity = 1.0;
    gesture.view.layer.shadowRadius = 5.0;
    gesture.view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    [gesture.view setNeedsDisplay];
    
    // Setup the image and dropshadow for the delete icon
    [CALayer circleLayer:self.deleteImage.layer];
    self.deleteImage.layer.cornerRadius = self.deleteImage.frame.size.height/2;
    self.deleteImage.layer.masksToBounds = YES;
    [self.deleteDropShadow addSubview:self.deleteImage];
    
    self.deleteImage.frame = CGRectMake(self.deleteDropShadow.frame.origin.x-40, self.deleteDropShadow.frame.origin.y-40, self.deleteDropShadow.frame.size.width, self.deleteDropShadow.frame.size.height);
    self.deleteDropShadow.clipsToBounds = NO;
    
    self.deleteDropShadow.layer.cornerRadius = self.deleteDropShadow.frame.size.height/2;
    self.deleteDropShadow.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.deleteDropShadow.layer.shadowOpacity = 1.0;
    self.deleteDropShadow.layer.shadowRadius = 5.0;
    self.deleteDropShadow.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    [self.deleteImage setImage:[UIImage imageNamed:@"delete.png"]];
    
    [self showImage:self.deleteImage];
    [self showImage:self.deleteDropShadow];
    [self.deleteDropShadow setNeedsDisplay];
    [self.view bringSubviewToFront:self.deleteDropShadow];

    [self showImage:self.deleteLabel];
    
    // Hide the actor label
    if (gesture.view.tag == 1) {
        self.firstActorLabel.alpha = ALPHA_FULL;
        self.secondActorLabel.alpha = ALPHA_FULL;
        self.secondActorImage.alpha = ALPHA_FULL;
        self.continueButton.alpha = ALPHA_FULL;
        self.deleteDropShadow.alpha = ALPHA_EMPTY;
        self.deleteImage.alpha = ALPHA_EMPTY;
        self.deleteLabel.alpha = ALPHA_EMPTY;
        // Then fades it away after 2 seconds (the cross-fade animation will take FADE_DURATIONs)
        [UIView animateWithDuration:FADE_DURATION delay:0.0 options:0 animations:^{
            // Animate the alpha value of your imageView from 1.0 to 0.0 here
            self.firstActorLabel.alpha = ALPHA_EMPTY;
            self.secondActorLabel.alpha = ALPHA_EMPTY;
            self.secondActorImage.alpha = ALPHA_EMPTY;
            self.continueButton.alpha = ALPHA_EMPTY;
            self.deleteDropShadow.alpha = ALPHA_FULL;
            self.deleteImage.alpha = ALPHA_FULL;
            self.deleteLabel.alpha = ALPHA_FULL;
        } completion:^(BOOL finished) {
            // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        }];
    }
    
    if (gesture.view.tag == 2) {
        self.secondActorLabel.alpha = ALPHA_FULL;
        self.firstActorLabel.alpha = ALPHA_FULL;
        self.firstActorImage.alpha = ALPHA_FULL;
        self.continueButton.alpha = ALPHA_FULL;
        self.deleteDropShadow.alpha = ALPHA_EMPTY;
        self.deleteImage.alpha = ALPHA_EMPTY;
        self.deleteLabel.alpha = ALPHA_EMPTY;
        // Then fades it away after 2 seconds (the cross-fade animation will take FADE_DURATIONs)
        [UIView animateWithDuration:FADE_DURATION delay:0.0 options:0 animations:^{
            // Animate the alpha value of your imageView from 1.0 to 0.0 here
            self.secondActorLabel.alpha = ALPHA_EMPTY;
            self.firstActorLabel.alpha = ALPHA_EMPTY;
            self.firstActorImage.alpha = ALPHA_EMPTY;
            self.continueButton.alpha = ALPHA_EMPTY;
            self.deleteDropShadow.alpha = ALPHA_FULL;
            self.deleteImage.alpha = ALPHA_FULL;
            self.deleteLabel.alpha = ALPHA_FULL;
        } completion:^(BOOL finished) {
            // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        }];
    }
}

- (void)endGestureFade:(UIGestureRecognizer *)gesture
{
    // Remove the drop shadow effect from the view
    gesture.view.layer.shadowOpacity = 0.0;
    
    // Show the actor label
    if (gesture.view.tag == 1) {
        self.firstActorLabel.alpha = ALPHA_EMPTY;
        self.secondActorLabel.alpha = ALPHA_EMPTY;
        self.secondActorImage.alpha = ALPHA_EMPTY;
        self.continueButton.alpha = ALPHA_EMPTY;
        self.deleteDropShadow.alpha = ALPHA_FULL;
        self.deleteImage.alpha = ALPHA_FULL;
        self.deleteLabel.alpha = ALPHA_FULL;
        // Then fades it away after 2 seconds (the cross-fade animation will take FADE_DURATIONs)
        [UIView animateWithDuration:FADE_DURATION delay:0.0 options:0 animations:^{
            // Animate the alpha value of your imageView from 1.0 to 0.0 here
            self.firstActorLabel.alpha = ALPHA_FULL;
            self.secondActorLabel.alpha = ALPHA_FULL;
            self.secondActorImage.alpha = ALPHA_FULL;
            self.continueButton.alpha = ALPHA_FULL;
            self.deleteDropShadow.alpha = ALPHA_EMPTY;
            self.deleteImage.alpha = ALPHA_EMPTY;
            self.deleteLabel.alpha = ALPHA_EMPTY;
        } completion:^(BOOL finished) {
            // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        }];
    }
    
    if (gesture.view.tag == 2) {
        self.secondActorLabel.alpha = ALPHA_EMPTY;
        self.firstActorLabel.alpha = ALPHA_EMPTY;
        self.firstActorImage.alpha = ALPHA_EMPTY;
        self.continueButton.alpha = ALPHA_EMPTY;
        self.deleteDropShadow.alpha = ALPHA_FULL;
        self.deleteImage.alpha = ALPHA_FULL;
        self.deleteLabel.alpha = ALPHA_FULL;
        // Then fades it away after 2 seconds (the cross-fade animation will take FADE_DURATIONs)
        [UIView animateWithDuration:FADE_DURATION delay:0.0 options:0 animations:^{
            // Animate the alpha value of your imageView from 1.0 to 0.0 here
            self.secondActorLabel.alpha = ALPHA_FULL;
            self.firstActorLabel.alpha = ALPHA_FULL;
            self.firstActorImage.alpha = ALPHA_FULL;
            self.continueButton.alpha = ALPHA_FULL;
            self.deleteDropShadow.alpha = ALPHA_EMPTY;
            self.deleteImage.alpha = ALPHA_EMPTY;
            self.deleteLabel.alpha = ALPHA_EMPTY;
        } completion:^(BOOL finished) {
            // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        }];
    }
}

@end
