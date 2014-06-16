//
//  TMWInfoViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 5/15/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWAboutViewController.h"

@interface TMWAboutViewController ()

@property (nonatomic, retain) IBOutlet UILabel *roleLabel;
@property (nonatomic, retain) IBOutlet UILabel *peopleLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *creditsScrollView;

@property (nonatomic, retain) UILabel *firstLabel;
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
        // Custom initialization
        //self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _firstLabel = [UILabel new];
    _firstLabel.frame = self.view.frame;
    _firstLabel.textAlignment = NSTextAlignmentCenter;
    _firstLabel.numberOfLines = 2;
    _firstLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30];
    _firstLabel.alpha = 0;
    _firstLabel.textColor = [UIColor whiteColor];
    
    
    //[self.view addSubview:_firstLabel];
    self.automaticallyAdjustsScrollViewInsets = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLayoutSubviews
{
    _creditsScrollView.frame = self.view.frame;
    _creditsScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 1162);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self addInfoButton];

}

- (void)addInfoButton
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"addInfoButton"
     object:self];
}

// TODO: Use NSNotificationCenter to alert when this
// view enters the foreground in the container view
- (void)viewDidAppear:(BOOL)animated
{
    creditsLength = 0;
    creditText = @[@"Directed by\nJay Hickey", @"Produced by\nJay Hickey",
                   @"Beta Testers\n"];
    
    // Get the version info
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    _buildLabel.text = [NSString stringWithFormat:@"Build %@ (%@)",
            majorVersion, minorVersion];
}



@end
