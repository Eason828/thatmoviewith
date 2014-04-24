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
#import "TMWCustomCellTableViewCell.h"
#import "TMWCustomAnimations.h"
#import "TMWActorModel.h"

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
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UIButton *backgroundButton;
@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *startSecondaryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *startArrow;

// Animation stuff
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;
@property (strong, nonatomic) UISnapBehavior *snapBehavior;
@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;

@end

@implementation TMWActorViewController

NSArray *backdropSizes;
NSArray *responseArray;
BOOL firstFlipped;
BOOL secondFlipped;

#define TABLE_HEIGHT 66

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
        
        self.firstActorLabel.hidden = YES;
        self.secondActorLabel.hidden = YES;
        self.continueButton.hidden = YES;
    }
    
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadImageConfiguration];
}


// Remove the actor
- (void)removeActor:(int)actorNum
{
    if ([self.firstActorLabel.text isEqualToString:@""] && [self.secondActorLabel.text isEqualToString:@""])
    {
        self.startLabel.hidden = NO;
        self.startSecondaryLabel.hidden = NO;
        [self.startArrow setImage: [UIImage imageNamed:@"arrow.png"]];
    }
    switch (actorNum) {
        
        case 1:
        {
            NSArray *chosenCopy = [TMWActorModel actorModel].chosenActors;
            for (NSDictionary *dict in chosenCopy) {
                if ([dict[@"name"] isEqualToString:self.firstActorLabel.text]) {
                    [[TMWActorModel actorModel] removeChosenActor:dict];
                    break;
                }
            }
            self.firstActorLabel.text = @"";
            break;
        }
        case 2:
        {
            NSArray *chosenCopy = [TMWActorModel actorModel].chosenActors;
            for (NSDictionary *dict in chosenCopy) {
                if ([dict[@"name"] isEqualToString:self.secondActorLabel.text]) {
                    [[TMWActorModel actorModel] removeChosenActor:dict];
                    break;
                }
            }
            self.secondActorLabel.text = @"";
            break;
        }
        
        // Only hide the continue button if there are not actors
        if ([TMWActorModel actorModel].chosenActors == nil)
        {
            self.continueButton.hidden = YES;
        }
    }
}

-(void)showImage:(UIImageView*)image
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
    [self.startArrow setImage:nil];
    
    [self.searchDisplayController setActive:NO animated:YES];
    
    // Remove the actor if both of the actors have been chosen
    if (![self.firstActorLabel.text isEqualToString:@""] && ![self.secondActorLabel.text isEqualToString:@""])
    {
        NSLog(@"Removing actor");
        NSArray *chosenCopy = [TMWActorModel actorModel].chosenActors;
        for (NSDictionary *dict in chosenCopy)
        {
            if ([dict[@"name"] isEqualToString: self.firstActorLabel.text] || [dict[@"name"] isEqualToString: self.secondActorLabel.text])
            {
                [[TMWActorModel actorModel] removeChosenActor:dict];
                break;
            }
        }
    }

    // Add the chosen actor to the array of chosen actors
    [[TMWActorModel actorModel] addChosenActor:[[TMWActorModel actorModel].actorSearchResults objectAtIndex:indexPath.row]];
    
    if ([self.firstActorLabel.text isEqualToString:@""])
    {
        // The second actor is the default selection for being replaced.
        self.firstActorImage.tag = 1;
        [self configureActorImageVisibility:self.firstActorImage
                              withTextLabel:self.firstActorLabel
                                atIndexPath:indexPath];
    }
    else
    {
        // The second actor is the default selection for being replaced.
        self.secondActorImage.tag = 2;
        [self configureActorImageVisibility:self.secondActorImage
                              withTextLabel:self.secondActorLabel
                                atIndexPath:indexPath];
    }
    
    if (![self.firstActorLabel.text isEqualToString:@""] || ![self.secondActorLabel.text isEqualToString:@""])
    {
        self.continueButton.tag = 3;
        self.backgroundButton.tag = 4;
        self.continueButton.hidden = NO;
                
        [self.continueButton.layer addAnimation:[TMWCustomAnimations buttonOpacityAnimation] forKey:@"opacity"];
        [[TMWActorModel actorModel] removeAllActorMovies];
    }

}


// Set the actor image and all of it's necessary properties
- (void)configureActorImageVisibility:(UIImageView *)actorImage
                   withTextLabel:(UILabel *)textLabel
                     atIndexPath:(NSIndexPath *)indexPath
{
    textLabel.hidden = NO;
    textLabel.alpha = 1.0;
    textLabel.text = [[TMWActorModel actorModel].actorSearchResultNames objectAtIndex:indexPath.row];
    
    // Make the image a circle
    [CALayer circleLayer:actorImage.layer];
    actorImage.contentMode = UIViewContentModeScaleAspectFill;
    
    // If NSString, fetch the image, else use the generated UIImage
    if ([[[[TMWActorModel actorModel] actorSearchResultImagesHiRes] objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        
        NSString *urlstring = [[self.imagesBaseUrlString stringByReplacingOccurrencesOfString:backdropSizes[1] withString:backdropSizes[4]] stringByAppendingString:[[TMWActorModel actorModel].actorSearchResultImagesHiRes objectAtIndex:indexPath.row]];
        
        [actorImage setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:[UIImage imageNamed:@"Clear.png"]];
    }
    else {
        [actorImage setImage:[[TMWActorModel actorModel].actorSearchResultImagesHiRes objectAtIndex:indexPath.row]];
    }
    [self showImage:actorImage];
    
    // Setup for dragging the image around
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [actorImage addGestureRecognizer:panGesture];
    
    //Setup for tapping on the image
    UITapGestureRecognizer *longPressOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [actorImage addGestureRecognizer:longPressOne];
    
    actorImage.userInteractionEnabled = YES;
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    [self.view bringSubviewToFront:actorImage];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[TMWActorModel actorModel].actorSearchResultNames count];
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

    cell.textLabel.text = [[TMWActorModel actorModel].actorSearchResultNames objectAtIndex:indexPath.row];

    // If NSString, fetch the image, else use the generated UIImage
    if ([[[TMWActorModel actorModel].actorSearchResultImagesLowRes objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        
        NSString *urlstring = [self.imagesBaseUrlString stringByAppendingString:[[TMWActorModel actorModel].actorSearchResultImagesLowRes objectAtIndex:indexPath.row]];
        
        // Show the network activity icon
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // Get the image from the URL and set it
        [cell.imageView setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:[UIImage imageNamed:@"Clear.png"]];
        
        // Hide the network activity icon
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    else {
        [cell.imageView setImage:[[TMWActorModel actorModel].actorSearchResultImagesLowRes objectAtIndex:indexPath.row]];
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
        
        if (!error) {
            [TMWActorModel actorModel].actorSearchResults = response[@"results"];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [[self.searchBarController searchResultsTableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
        // Hide the actor label
        if (gesture.view.tag == 1) {
            self.firstActorLabel.alpha = 1.0f;
            // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
            [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
                // Animate the alpha value of your imageView from 1.0 to 0.0 here
                self.firstActorLabel.alpha = 0.0f;
            } completion:^(BOOL finished) {
                // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
            }];
        }
        
        if (gesture.view.tag == 2) {
            self.secondActorLabel.alpha = 1.0f;
            // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
            [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
                // Animate the alpha value of your imageView from 1.0 to 0.0 here
                self.secondActorLabel.alpha = 0.0f;
            } completion:^(BOOL finished) {
                // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
            }];
        }
        
        [self.animator removeAllBehaviors];

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

        // if we aren't dragging it down, just snap it back and quit
        CGPoint velocity = [gesture velocityInView:self.view];
        CGFloat velocityMagnitude = hypot(velocity.x, velocity.y);
        CGFloat triggerVelocity = 500;
        if (velocityMagnitude<triggerVelocity) {
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
            [self.animator addBehavior:snap];
            
            // Show the actor label
            if (gesture.view.tag == 1) {
                self.firstActorLabel.alpha = 0.0f;
                // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
                [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
                    // Animate the alpha value of your imageView from 1.0 to 0.0 here
                    self.firstActorLabel.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
                }];
            }
            
            if (gesture.view.tag == 2) {
                self.secondActorLabel.alpha = 0.0f;
                // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
                [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
                    // Animate the alpha value of your imageView from 1.0 to 0.0 here
                    self.secondActorLabel.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
                }];
            }

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
                [self.animator removeAllBehaviors];
                gesture.view.hidden = YES;
                UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
                [self.animator addBehavior:snap];
                [self removeActor:gesture.view.tag];
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

@end
