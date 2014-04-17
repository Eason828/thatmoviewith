//
//  TMWViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/15/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "TMWViewController.h"
#import "TMWActors.h"
#import "TMWCustomCellTableViewCell.h"

#define TABLE_HEIGHT 66

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

@end

@implementation TMWViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.actors = [[TMWActors alloc] init];
        
        [self.firstActorLabel setHidden:YES];
        self.firstActorImage.frame = CGRectMake(0,0,20,20);
        self.firstActorButton.enabled = NO;
        self.firstActorButton.tag = 1;
        
        [self.secondActorLabel setHidden:YES];
        self.secondActorImage.frame = CGRectMake(0,0,20,20);
        self.secondActorButton.enabled = NO;
        self.firstActorButton.tag = 2;
        
        [self.continueButton setHidden:YES];
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
}

#pragma mark UITableView methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchDisplayController setActive:NO animated:YES];
    
    if ([self.firstActorLabel.text isEqualToString:@""])
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
    
    if ([self.firstActorLabel.text isEqualToString:@""] && [self.secondActorLabel.text isEqualToString:@""])
    {
        [self.continueButton setHidden:NO];
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
    [cell.imageView setImageWithURL:[NSURL URLWithString:[self.actorImageURLs objectAtIndex:indexPath.row]] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
    
    return cell;
}

//- (IBAction)buttonPressed:(id)sender
//{
//    switch ( ((UIButton*)sender).tag ){
//            
//        case 1:
//            NSLog(@"Button 1!");
//            break;
//        case 2:
//            NSLog(@"Button 2!");
//                break;
//            
//        default:
//            NSLog(@"%ld", (long)((UIButton*)sender).tag);
//    }
//}
-(IBAction)buttonPressed:(id)sender{
    UIButton *button = (UIButton *)sender;
    NSLog(@"Tag: %d", [button tag]);
}
@end
