//
//  TMWViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/15/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWViewController.h"
#import "TMWActors.h"

@interface TMWViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;
@property (strong, nonatomic) TMWActors *actors;
@property (nonatomic, retain) NSArray *actorNames;
@property (nonatomic, retain) NSMutableArray *actorImages;

@end

@implementation TMWViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.actors = [[TMWActors alloc] init];
    }
    return self;
}

#pragma mark UISearchBar methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText length] != 0) {
        self.actorImages = [[NSMutableArray alloc] init];
        NSArray *actorsObject = [self.actors retrieveActorDataResultsForQuery:searchText];
        self.actorNames = [self.actors retrieveActorNamesForActorDataResults:actorsObject];
        for (NSDictionary *actor in actorsObject)
        {
            [self.actorImages addObject:[self.actors retriveActorImagesForActorDataResults:actor[@"profile_path"]]];
        }
        
        [[self.searchBarController searchResultsTableView] reloadData];

    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel clicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
}

#pragma mark UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.actorNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [self.actorNames objectAtIndex:indexPath.row];
    cell.imageView.image = [self.actorImages objectAtIndex:indexPath.row];
    
    return cell;
}




@end
