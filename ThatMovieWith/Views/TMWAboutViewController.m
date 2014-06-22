//
//  TMWInfoViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 5/15/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWAboutViewController.h"
#import "TMWAutoScroll.h"

@interface TMWAboutViewController () <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *creditsScrollView;
@property (nonatomic, retain) IBOutlet UIView *endView;
@property (nonatomic, retain) IBOutlet UILabel *buildLabel;

@end

@implementation TMWAboutViewController

NSUInteger creditsLength;
NSArray *creditText;
int cnt;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationController.navigationBar.backgroundColor = [UIColor blueColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIView beginAnimations:@"showStatusBar" context:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIView setAnimationDuration:0.0];
    [UIView commitAnimations];
}

// TODO: Use NSNotificationCenter to alert when this
// view enters the foreground in the container view
- (void)viewDidAppear:(BOOL)animated
{
    // Get the version info
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    _buildLabel.text = [NSString stringWithFormat:@"Build %@ (%@)",
                        majorVersion, minorVersion];
    
    
    // Setup the auto scrolling
    _creditsScrollView.scrollPointsPerSecond = 30.0f;
    [_creditsScrollView startScrolling];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIView beginAnimations:@"showStatusBar" context:nil];
    [UIView setAnimationDuration:0.0];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [UIView commitAnimations];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // Bring the scroll view back to the top
    [_creditsScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self addInfoButton];
}

# pragma mark ScrollView Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [_creditsScrollView startScrolling];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_creditsScrollView startScrolling];
}

# pragma mark Private Methods

- (void)addInfoButton
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"addInfoButton"
     object:self];
}



@end
