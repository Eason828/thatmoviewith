//
//  PhotosCollectionViewController.m
//  ParallaxScrolling
//
//  Created by Ole Begemann on 01.05.14.
//  Copyright (c) 2014 Ole Begemann. All rights reserved.
//

#import "TMWMoviesCollectionViewController.h"
#import "ParallaxFlowLayout.h"
#import "ParallaxPhotoCell.h"

#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>
#import "SVWebViewController.h"
#import "TMWActorContainer.h"
#import "UIImage+DrawInitialsOnImage.h" // Actor's without images
#import "UIImage+ImageEffects.h"
#import "UIColor+customColors.h"

@interface TMWMoviesCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) NSArray *photos;

@end


@implementation TMWMoviesCollectionViewController

static const NSUInteger TABLE_HEIGHT = 198;
static const NSUInteger TITLE_FONT_SIZE = 36;

NSInteger tableViewRows;
CGFloat cellWidth;


- (id)init
{
    ParallaxFlowLayout *layout = [[ParallaxFlowLayout alloc] init];
    layout.minimumLineSpacing = 16;
    //layout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16);
    
    self = [super initWithCollectionViewLayout:layout];
    
    if (self == nil) {
        return nil;
    }
    
    self.title = @"Movies";
    
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[ParallaxPhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];

    // Set the back button color
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor goldColor];
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    self.navigationController.navigationBar.backItem.title = @"Actors";
    self.navigationController.navigationBar.alpha = 0.85;
    
    tableViewRows = 0;
    
    // Refresh the table view
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    // For when dismissing the view controller
    // TODO: Find a method to put this in before the
    // view is shown. viewWillAppear doesn't work.
    self.navigationController.navigationBar.alpha = 0.85;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return tableViewRows;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __weak ParallaxPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    // grab bound for contentView
    CGRect contentViewBound = cell.imageView.bounds;
    
    // If an image exists, fetch it. Else use the generated UIImage
    if ([[TMWActorContainer actorContainer].sameMoviesPosterUrlEndings objectAtIndex:indexPath.row] != (id)[NSNull null]) {
        NSString *urlstring = [[[TMWActorContainer actorContainer].imagesBaseURLString stringByReplacingOccurrencesOfString:[TMWActorContainer actorContainer].backdropSizes[1] withString:[TMWActorContainer actorContainer].backdropSizes[5]] stringByAppendingString:[[TMWActorContainer actorContainer].sameMoviesPosterUrlEndings objectAtIndex:indexPath.row]];
        
        // Show the network activity icon
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        
        // Get the image from the URL and set it
        [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]] placeholderImage:[UIImage imageNamed:@"MoviesBackgroundHiRes"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            NSString *movieNameString = [[TMWActorContainer actorContainer].sameMoviesNames objectAtIndex:indexPath.row];
            
            UIImage *darkImage = [image applyPosterEffect];
            UIImage *initialsImage = [UIImage imageByDrawingMovieNameOnImage:darkImage withMovieName:movieNameString withFontSize:TITLE_FONT_SIZE];
            cell.imageView.image = initialsImage;
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Request failed with error: %@", error);
        }];

        CGRect imageViewFrame = cell.imageView.frame;
        // change x position
        imageViewFrame.origin.y = contentViewBound.size.height - imageViewFrame.size.height;
        // assign the new frame
        cell.imageView.frame = imageViewFrame;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        // Hide the network activity icon
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    else {
        UIImage *defaultImage = [UIImage imageNamed:@"MoviesBackgroundHiRes"];
        NSString *movieNameString = [[TMWActorContainer actorContainer].sameMoviesNames objectAtIndex:indexPath.row];
        
        UIImage *darkImage = [defaultImage applyPosterEffect];
        UIImage *initialsImage = [UIImage imageByDrawingMovieNameOnImage:darkImage withMovieName:movieNameString withFontSize:TITLE_FONT_SIZE];
        cell.imageView.image = initialsImage;
    }

    
    // Pass the maximum parallax offset to the cell.
    // The cell needs this information to configure the constraints for its image view.
    ParallaxFlowLayout *layout = (ParallaxFlowLayout *)self.collectionViewLayout;
    cell.maxParallaxOffset = layout.maxParallaxOffset;
    
    
    return cell;
}

- (void)refresh
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Fetch the movie data for all actors in the container
    __block NSUInteger i = 1;
    for (TMWActor *actor in [TMWActorContainer actorContainer].allActorObjects) {
        
        __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
        
        [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbPersonCredits withParameters:@{@"id":actor.IDNumber} andResponseBlock:^(id response, NSError *error) {
            
            if (!error) {
                actor.movies = [[NSArray alloc] initWithArray:response[@"cast"]];
                if (i == [[TMWActorContainer actorContainer].allActorObjects count]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        tableViewRows = [[TMWActorContainer actorContainer].sameMoviesNames count];
                        if([[TMWActorContainer actorContainer].sameMoviesNames count] == 0 ){
                            // TODO: Fix no results view
                            //self.collectionView.hidden = YES;
//                            self.noResultsView.hidden = NO;
                        } else {
//                            self.moviesTableView.hidden = NO;
//                            self.noResultsView.hidden = YES;
                        }
                        [self.collectionView reloadData];
                    });
                }
                i++;
            }
            else {
                [errorAlertView show];
            }
        }];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the information about the selected movie
    [self refreshMovieResponseWithJLTMDBcall:kJLTMDbMovie
                              withParameters:@{@"id":[[TMWActorContainer actorContainer].sameMoviesIDs objectAtIndex:indexPath.row]}];
    
}

// Gets the movies each actor has been in, along with the urls
- (void) refreshMovieResponseWithJLTMDBcall:(NSString *)JLTMDBCall withParameters:(NSDictionary *)parameters
{
    
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[JLTMDbClient sharedAPIInstance] GET:JLTMDBCall withParameters:parameters andResponseBlock:^(id response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        
        if (!error) {
            NSDictionary *movieInfo = [[NSDictionary alloc] initWithDictionary:response];
            
            NSString *webURL = [@"http://imdb.com/title/" stringByAppendingString:movieInfo[@"imdb_id"]];
            NSLog(@"%@", webURL);
            SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:webURL];
            webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
            webViewController.barsTintColor = [UIColor blackColor];
            
            [self presentViewController:webViewController animated:YES completion:NULL];
        }
        else {
            [errorAlertView show];
        }
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Compute cell size according to image aspect ratio.
    // Cell height must take maximum possible parallax offset into account.
    ParallaxFlowLayout *layout = (ParallaxFlowLayout *)self.collectionViewLayout;
    cellWidth = CGRectGetWidth(self.collectionView.bounds) - layout.sectionInset.left - layout.sectionInset.right;
//    CGFloat cellHeight = floor(cellWidth / imageWidth * imageHeight) - (2 * layout.maxParallaxOffset);
    return CGSizeMake(cellWidth, TABLE_HEIGHT);
}

@end
