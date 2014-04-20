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

@interface TMWActorViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;
@property (strong, nonatomic) IBOutlet UILabel *firstActorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *firstActorImage;
@property (strong, nonatomic) IBOutlet UILabel *secondActorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *secondActorImage;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UIButton *firstActorButton;
@property (strong, nonatomic) IBOutlet UIButton *secondActorButton;
@property (strong, nonatomic) IBOutlet UIButton *backgroundButton;
@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *startSecondaryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *startArrow;

@end

@implementation TMWActorViewController

NSInteger selectedActor;
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
        
        [self.firstActorLabel setHidden:YES];
        self.firstActorImage.frame = CGRectMake(0,0,20,20);
        self.firstActorButton.enabled = NO;
        
        [self.secondActorLabel setHidden:YES];
        self.secondActorImage.frame = CGRectMake(0,0,20,20);
        self.secondActorButton.enabled = NO;
        
        self.continueButton.hidden = YES;
    }
    
    return self;
}
-(void)viewDidLayoutSubviews{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadImageConfiguration];
    
    UILongPressGestureRecognizer *longPressOne = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOne:)];
    longPressOne.minimumPressDuration = 1.0;
    [self.firstActorButton addGestureRecognizer:longPressOne];
    UILongPressGestureRecognizer *longPressTwo = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTwo:)];
    longPressTwo.minimumPressDuration = 1.0;
    [self.secondActorButton addGestureRecognizer:longPressTwo];
}



- (void)longPressOne:(UILongPressGestureRecognizer*)gesture {
    NSLog(@"Long Press 1");
    
    int num = 1;
    [self removeActor:&num];
    
    
}

- (void)longPressTwo:(UILongPressGestureRecognizer*)gesture {
    NSLog(@"Long Press 2");
    
    int num = 2;
    [self removeActor:&num];

}

// Remove the actor and all the ne
- (void)removeActor:(int *)actorNumber {
    
    [self.continueButton setHidden: YES];
    [self.firstActorLabel.layer removeAllAnimations];
    [self.secondActorLabel.layer removeAllAnimations];
    [self.firstActorImage.layer removeAllAnimations];
    [self.secondActorImage.layer removeAllAnimations];
    
    if ([self.firstActorLabel.text isEqualToString:@""] && [self.secondActorLabel.text isEqualToString:@""])
    {
        [self.startLabel setHidden:NO];
        [self.startSecondaryLabel setHidden:NO];
        [self.startArrow setImage: nil];
    }
    
    switch (*actorNumber) {
        
        case 1:
        {
            NSArray *chosenCopy = [TMWActorModel actorModel].chosenActors;
            
            for (NSDictionary *dict in chosenCopy)
            {
                if ([dict[@"name"] isEqualToString: self.firstActorLabel.text])
                {
                    [[TMWActorModel actorModel] removeChosenActor:dict];
                    break;
                }
            }
            
            self.firstActorButton.enabled = NO;
            [self.firstActorImage setImage: nil];
            self.firstActorLabel.text = @"";
            
            break;
        }
        case 2:
        {
            NSArray *chosenCopy = [TMWActorModel actorModel].chosenActors;
            
            for (NSDictionary *dict in chosenCopy)
            {
                if ([dict[@"name"] isEqualToString: self.secondActorLabel.text])
                {
                    [[TMWActorModel actorModel] removeChosenActor:dict];
                    break;
                }
            }
            
            self.secondActorButton.enabled = NO;
            [self.secondActorImage setImage: nil];
            self.secondActorLabel.text = @"";
            
            break;
        }
            
        default:
        {
            //
        }
    }
    
    
}

#pragma mark UISearchBar methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText length] != 0) {
        
        // Search for people
        [self refreshActorResponseWithJLTMDBcall:kJLTMDbSearchPerson withParameters:@{@"search_type":@"ngram",@"query":searchText}];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel clicked");
}

// TODO: Add a method here to grab the first item from the search
// and (if 2 actors have been chosen, perform the search
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
}

#pragma mark UITableView methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.startLabel setHidden:YES];
    [self.startSecondaryLabel setHidden:YES];
    [self.startArrow setImage:nil];
    
    [self.searchDisplayController setActive:NO animated:YES];
    
    // Remove the actor if both of the actors have been chosen
    if (![self.firstActorLabel.text isEqualToString:@""] && ![self.secondActorLabel.text isEqualToString:@""])
    {
        NSLog(@"Removing actor");
        NSArray *chosenCopy = [TMWActorModel actorModel].chosenActors;
        for (NSDictionary *dict in chosenCopy)
        {
            if ((selectedActor == 1 && [dict[@"name"] isEqualToString: self.firstActorLabel.text]) || (selectedActor == 2 && [dict[@"name"] isEqualToString: self.secondActorLabel.text]))
            {
                [[TMWActorModel actorModel] removeChosenActor:dict];
                break;
            }
        }

    }

    // Add the chosen actor to the array of chosen actors
    [[TMWActorModel actorModel] addChosenActor:[[TMWActorModel actorModel].actorSearchResults objectAtIndex:indexPath.row]];
    
    if ([self.firstActorLabel.text isEqualToString:@""]||(selectedActor == 1))
    {
        self.firstActorLabel.text = [[TMWActorModel actorModel].actorSearchResultNames objectAtIndex:indexPath.row];

        // Make the image a circle
        [CALayer circleLayer:self.firstActorImage.layer];
        self.firstActorImage.contentMode = UIViewContentModeScaleAspectFill;
        
        // TODO: Make these their own methods
        // If NSString, fetch the image, else use the generated UIImage
        if ([[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {

            NSString *urlstring = [[self.imagesBaseUrlString stringByReplacingOccurrencesOfString:backdropSizes[1] withString:backdropSizes[3]] stringByAppendingString:[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row]];
            
            [self.firstActorImage setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:nil];
        }
        else {
            // TODO: Fix issue with image font being blurry when actor without a picture is chosen
            [self.firstActorImage setImage:[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row]];
        }
        
        // Enable tapping on the actor image
        self.firstActorButton.enabled = YES;
        
        // The second actor is the default selection for being replaced.
        selectedActor = 2;
    }
    else
    {
        self.secondActorLabel.text = [[TMWActorModel actorModel].actorSearchResultNames objectAtIndex:indexPath.row];

        // Make the image a circle
        [CALayer circleLayer:self.secondActorImage.layer];
        self.secondActorImage.contentMode = UIViewContentModeScaleAspectFill;
        
        // If NSString, fetch the image, else use the generated UIImage
        if ([[[[TMWActorModel actorModel] actorSearchResultImages] objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
            
            NSString *urlstring = [[self.imagesBaseUrlString stringByReplacingOccurrencesOfString:backdropSizes[1] withString:backdropSizes[3]] stringByAppendingString:[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row]];
            
            [self.secondActorImage setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:[UIImage imageNamed:@"Clear.png"]];
        }
        else {
            [self.secondActorImage setImage:[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row]];
        }
        
        // Enable tapping on the actor image
        self.secondActorButton.enabled = YES;
        
        // The second actor is the default selection for being replaced.
        selectedActor = 2;
    }
    
    if (![self.firstActorLabel.text isEqualToString:@""] && ![self.secondActorLabel.text isEqualToString:@""])
    {
        self.firstActorButton.tag = 1;
        self.secondActorButton.tag = 2;
        self.continueButton.tag = 3;
        self.backgroundButton.tag = 4;
        [self.continueButton setHidden:NO];
                
        [self.continueButton.layer addAnimation:[TMWCustomAnimations buttonOpacityAnimation] forKey:@"opacity"];
        [self.firstActorImage.layer removeAllAnimations];
        [self.secondActorImage.layer removeAllAnimations];
        
        [[TMWActorModel actorModel] removeAllActorMovies];
        for (id actorID in [TMWActorModel actorModel].chosenActorsIDs)
        {
            [self refreshMovieResponseWithJLTMDBcall:kJLTMDbPersonCredits
                                      withParameters:@{@"id":actorID}];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[TMWActorModel actorModel].actorSearchResultNames count];
}

//Change the Height of the Cell [Default is 44]:
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return TABLE_HEIGHT;
}

// Todo: add fade in animation to searching
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];    // Configure the cell...
    //[tableView setSeparatorInset:UIEdgeInsetsMake(0, IMAGE_SIZE+IMAGE_LEFT_OFFSET+IMAGE_TEXT_OFFSET, 0, 0)];
    
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
//    cell.backgroundColor = [UIColor clearColor];
//    tableView.backgroundColor = [UIColor clearColor];


    //cell.textLabel.font = [UIFont systemFontOfSize:UIFont.systemFontSize];
    cell.textLabel.text = [[TMWActorModel actorModel].actorSearchResultNames objectAtIndex:indexPath.row];

    // If NSString, fetch the image, else use the generated UIImage
    if ([[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        
        NSString *urlstring = [self.imagesBaseUrlString stringByAppendingString:[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row]];
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:[UIImage imageNamed:@"Clear.png"]];
    }
    else {
        [cell.imageView setImage:[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row]];
    }
    return cell;
}

#pragma mark UIButton methods

// For flipping over the actor images
-(IBAction)buttonPressed:(id)sender{
    UIButton *button = (UIButton *)sender;
    
    switch ([button tag]) {
        case 1:
        {

//            [UIView transitionWithView:self.firstActorImage duration:1.5
//                               options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
//                                   self.firstActorImage.image = self.secondActorImage.image;
//                               } completion:nil];
            break;
        }
            
        case 2:
        {
//            if (firstFlipped == NO) {
//                [UIView transitionWithView:self.secondActorImage duration:1.5
//                                   options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
//                                       self.secondActorImage.image = self.firstActorImage.image;
//                                   } completion:nil];
//                firstFlipped = YES;
//            }
//            else {
//                [UIView transitionWithView:self.secondActorImage duration:1.5
//                                   options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
//                                       self.firstActorImage.image = self.secondActorImage.image;
//                                   } completion:nil];
//                firstFlipped = NO;
//            }
            break;
        }

        case 3: // Continue button
        case 4: // Background button
        {
            // Stop all animations when the continueButton is pressed
            [self.firstActorLabel.layer removeAllAnimations];
            [self.secondActorLabel.layer removeAllAnimations];
            [self.firstActorImage.layer removeAllAnimations];
            [self.secondActorImage.layer removeAllAnimations];
            
            // Show the Movies View if the continue button is pressed
            if ([button tag] == 3) {
                
                TMWMoviesViewController *moviesViewController = [[TMWMoviesViewController alloc] init];
                [self.navigationController pushViewController:moviesViewController animated:YES];
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            }
            break;
        }
    }
}

-(IBAction)buttonDown:(id)sender{
    UIButton *button = (UIButton *)sender;
    
    switch ([button tag]) {
        case 1:
        {
            selectedActor = 1;
            self.firstActorImage.layer.borderColor = [UIColor ringBlueColor].CGColor;
            
            // Animate the first actor image and name
            [self.firstActorLabel.layer addAnimation:[TMWCustomAnimations actorOpacityAnimation] 
                                              forKey:@"opacity"];
            [self.firstActorImage.layer addAnimation:[TMWCustomAnimations ringBorderWidthAnimation] 
                                              forKey:@"borderWidth"]; //
            [self.secondActorImage.layer removeAllAnimations];
            [self.continueButton.layer removeAllAnimations];
            
            break;
        }
            
        case 2:
        {
            selectedActor = 2;
            self.secondActorImage.layer.borderColor = [UIColor ringBlueColor].CGColor;             
            
            // Animate the second actor image and name
            [self.secondActorLabel.layer addAnimation:[TMWCustomAnimations actorOpacityAnimation] 
                                               forKey:@"opacity"];
            [self.secondActorImage.layer addAnimation:[TMWCustomAnimations ringBorderWidthAnimation] 
                                               forKey:@"borderWidth"]; //
            [self.firstActorImage.layer removeAllAnimations];
            [self.continueButton.layer removeAllAnimations];
            
            break;
        }
        case 3: // Continue button
        case 4: // Background button
        {
            break;
        }
            
        default:
        {
            NSLog(@"No tag");
        }
    }
}


#pragma mark Private Methods

- (NSArray *)organizeSearchResultsByImageWithArray:(NSArray *)results
{
    NSMutableArray *mutableResults = [NSMutableArray arrayWithArray:results];
    for (NSDictionary *person in results)
    {
        if (person[@"profile_path"] == (id)[NSNull null])
        {
            [mutableResults removeObject:person];
            [mutableResults addObject:person];
        }
    }
    return [NSArray arrayWithArray:mutableResults];
}

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

- (void) refreshActorResponseWithJLTMDBcall:(NSString *)JLTMDBCall withParameters:(NSDictionary *) parameters
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[JLTMDbClient sharedAPIInstance] GET:JLTMDBCall withParameters:parameters andResponseBlock:^(id response, NSError *error) {
        
        if (!error) {
            [TMWActorModel actorModel].actorSearchResults = [self organizeSearchResultsByImageWithArray:response[@"results"]];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [[self.searchBarController searchResultsTableView] reloadData];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
        }
        else {
            [errorAlertView show];
        }
    }];
}

- (void) refreshMovieResponseWithJLTMDBcall:(NSString *)JLTMDBCall withParameters:(NSDictionary *) parameters
{
    
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[JLTMDbClient sharedAPIInstance] GET:JLTMDBCall withParameters:parameters andResponseBlock:^(id response, NSError *error) {
        
        if (!error) {
            [[TMWActorModel actorModel] addActorMovies:response[@"cast"]];
        }
        else {
            [errorAlertView show];
        }
    }];
}

@end
