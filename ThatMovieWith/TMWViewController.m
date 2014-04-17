//
//  TMWViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/15/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "TMWViewController.h"
#import "TMWActors.h"
#import "TMWCustomCellTableViewCell.h"

@interface TMWViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;
@property (strong, nonatomic) IBOutlet UILabel *firstActorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *firstActorImage;
@property (strong, nonatomic) IBOutlet UILabel *secondActorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *secondActorImage;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UIButton *firstActorButton;
@property (strong, nonatomic) IBOutlet UIButton *secondActorButton;


@property (strong, nonatomic) TMWActors *actors;
@property (nonatomic, retain) NSArray *actorNames;
@property (nonatomic, retain) NSArray *actorImageURLs;
@property (nonatomic) NSInteger selectedActor;

@end

@implementation TMWViewController

#define TABLE_HEIGHT 66

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.actors = [[TMWActors alloc] init];
        
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

#pragma mark UISearchBar methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText length] != 0) {
        NSArray *actorsObject = [self.actors retrieveActorDataResultsForQuery:searchText];
        self.actorNames = [self.actors retrieveActorNamesForActorDataResults:actorsObject];
        self.actorImageURLs = [self.actors retriveActorImageURLsForActorDataResults:actorsObject];
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
    [self.searchDisplayController setActive:NO animated:YES];
    
    if ([self.firstActorLabel.text isEqualToString:@""]||(self.selectedActor == 1))
    {
        self.firstActorLabel.text = [self.actorNames objectAtIndex:indexPath.row];
        self.firstActorImage.layer.cornerRadius = self.firstActorImage.frame.size.height/2;
        self.firstActorImage.layer.masksToBounds = YES;
        self.firstActorImage.layer.borderWidth = 0;
        self.firstActorImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.firstActorImage setImageWithURL:[NSURL URLWithString:[self.actorImageURLs objectAtIndex:indexPath.row]]];
        self.firstActorButton.enabled = YES;
    }
    else
    {
        self.secondActorLabel.text = [self.actorNames objectAtIndex:indexPath.row];
        self.secondActorImage.layer.cornerRadius = self.secondActorImage.frame.size.height/2;
        self.secondActorImage.layer.masksToBounds = YES;
        self.secondActorImage.layer.borderWidth = 0;
        self.secondActorImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.secondActorImage setImageWithURL:[NSURL URLWithString:[self.actorImageURLs objectAtIndex:indexPath.row]]];
        self.secondActorButton.enabled = YES;
    }
    
    if (![self.firstActorLabel.text isEqualToString:@""] && ![self.secondActorLabel.text isEqualToString:@""])
    {
        self.firstActorButton.tag = 1;
        self.secondActorButton.tag = 2;
        self.continueButton.tag = 3;
        [self.continueButton setHidden:NO];
        
        // TODO: Make this a function
        CABasicAnimation *theAnimation;
        
        theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        theAnimation.duration=2.0;
        theAnimation.repeatCount=HUGE_VALF;
        theAnimation.autoreverses=YES;
        theAnimation.fromValue=[NSNumber numberWithFloat:0.3];
        theAnimation.toValue=[NSNumber numberWithFloat:1.0];
        
        [self.continueButton.layer addAnimation:theAnimation forKey:@"opacity"];
        [self.firstActorImage.layer removeAllAnimations];
        [self.secondActorImage.layer removeAllAnimations];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.actorNames count];
}

//Change the Height of the Cell [Default is 44]:
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return TABLE_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    TMWCustomCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TMWCustomCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height/2;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderWidth = 0;
//    cell.backgroundColor = [UIColor clearColor];
//    tableView.backgroundColor = [UIColor clearColor];

    
    // Configure the cell...
    //cell.textLabel.font = [UIFont systemFontOfSize:UIFont.systemFontSize];
    cell.textLabel.text = [self.actorNames objectAtIndex:indexPath.row];
    // TODO: Create a method that returns a UIImage when passed a actor name (for the placeholder)
    [cell.imageView setImageWithURL:[NSURL URLWithString:[self.actorImageURLs objectAtIndex:indexPath.row]] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
    
    return cell;
}

-(IBAction)buttonPressed:(id)sender{
    UIButton *button = (UIButton *)sender;
    
    switch ([button tag]) {
        case 1:
        {
            NSLog(@"Tag 1: %d", [button tag]);
            self.selectedActor = 1;
            self.firstActorImage.layer.borderWidth = 3.0f;
            self.secondActorImage.layer.borderWidth = 0.0f;
            self.firstActorImage.layer.borderColor = [UIColor colorWithRed:22.0/255 green:126.0/255 blue:230.0/255 alpha:1.0].CGColor;
            
            if (self.firstActorImage.layer.borderWidth > 0.0f)
            {
                NSLog(@"Getting ready to animate");
                
                CABasicAnimation *theOpAnimation;
                
                theOpAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
                theOpAnimation.duration=1.0;
                theOpAnimation.repeatCount=HUGE_VALF;
                theOpAnimation.autoreverses=YES;
                theOpAnimation.fromValue=[NSNumber numberWithFloat:0.5];
                theOpAnimation.toValue=[NSNumber numberWithFloat:1.0];
                
                [self.firstActorLabel.layer addAnimation:theOpAnimation forKey:@"opacity"];
                
                CABasicAnimation *theAnimation;
                
                theAnimation=[CABasicAnimation animationWithKeyPath:@"borderWidth"];
                theAnimation.duration=1.0;
                theAnimation.repeatCount=HUGE_VALF;
                theAnimation.autoreverses=YES;
                theAnimation.fromValue=[NSNumber numberWithFloat:1.5];
                theAnimation.toValue=[NSNumber numberWithFloat:4.0];
                [self.firstActorImage.layer addAnimation:theAnimation forKey:@"borderWidth"]; //
                [self.secondActorImage.layer removeAllAnimations];
                [self.continueButton.layer removeAllAnimations];
            }
            break;
        }
            
        case 2:
        {
            NSLog(@"Tag 2: %d", [button tag]);
            self.selectedActor = 2;
            self.firstActorImage.layer.borderWidth = 0.0f;
            self.secondActorImage.layer.borderWidth = 3.0f;
            self.secondActorImage.layer.borderColor = [UIColor colorWithRed:22.0/255 green:126.0/255 blue:230.0/255 alpha:1.0].CGColor;
            if (self.secondActorImage.layer.borderWidth > 0.0f)
            {
                NSLog(@"Getting ready to animate");
                CABasicAnimation *theOpAnimation;
                
                theOpAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
                theOpAnimation.duration=1.0;
                theOpAnimation.repeatCount=HUGE_VALF;
                theOpAnimation.autoreverses=YES;
                theOpAnimation.fromValue=[NSNumber numberWithFloat:0.5];
                theOpAnimation.toValue=[NSNumber numberWithFloat:1.0];
                
                [self.secondActorLabel.layer addAnimation:theOpAnimation forKey:@"opacity"];
                
                CABasicAnimation *theAnimation;
                
                theAnimation=[CABasicAnimation animationWithKeyPath:@"borderWidth"];
                theAnimation.duration=1.0;
                theAnimation.repeatCount=HUGE_VALF;
                theAnimation.autoreverses=YES;
                theAnimation.fromValue=[NSNumber numberWithFloat:1.5];
                theAnimation.toValue=[NSNumber numberWithFloat:4.0];
                [self.secondActorImage.layer addAnimation:theAnimation forKey:@"borderWidth"]; //
                [self.firstActorImage.layer removeAllAnimations];
                [self.continueButton.layer removeAllAnimations];
            }
            break;
        }
        case 3:
        {
            [self.firstActorLabel.layer removeAllAnimations];
            [self.secondActorLabel.layer removeAllAnimations];
            [self.firstActorImage.layer removeAllAnimations];
            [self.secondActorImage.layer removeAllAnimations];
            self.firstActorImage.layer.borderWidth = 0.0f;
            self.secondActorImage.layer.borderWidth = 0.0f;
            break;
        }
            
        default:
        {
            NSLog(@"No tag");
        }
    }
}

@end
