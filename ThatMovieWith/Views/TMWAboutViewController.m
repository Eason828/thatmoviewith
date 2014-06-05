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
@property (nonatomic, retain) IBOutlet UIScrollView *movieScrollView;

@property (nonatomic, retain) UILabel *firstLabel;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;

@end

@implementation TMWAboutViewController

NSUInteger creditsLength;
NSArray *creditText;
int cnt;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    //self.firstLabel.text = @"Directed by\nJay Hickey";
    _firstLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30];
    _firstLabel.alpha = 0;
    _firstLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_firstLabel];
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
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    _versionLabel.text = [NSString stringWithFormat:@"%@, Version %@ (%@)",
            appDisplayName, majorVersion, minorVersion];

    
    //[self performSelector:@selector(delayAnimateCreditsWithCount) withObject:nil afterDelay:5.0];
    
    [NSTimer scheduledTimerWithTimeInterval:9.0
                                     target:self
                                   selector:@selector(delayAnimateCreditsWithCount)
                                   userInfo:nil
                                    repeats:NO];
    
//    [NSTimer scheduledTimerWithTimeInterval:5.0
//                                     target:self
//                                   selector:@selector(labelRequest)
//                                   userInfo:nil
//                                    repeats:NO];
//    
//    [NSTimer scheduledTimerWithTimeInterval:5.0
//                                     target:self
//                                   selector:@selector(labelRequest)
//                                   userInfo:nil
//                                    repeats:NO];
}

- (void)delayAnimateCreditsWithCount
{
    [self animateCreditsWithCount:0];
}

- (void)animateCreditsWithCount:(NSUInteger)count
{
    if(count > creditText.count-1) {
        count = 0;
    }

    _firstLabel.text = creditText[count];
    
    _firstLabel.alpha = 1.0;
    
    [UIView animateWithDuration:0 delay:3.0 options:0 animations:^{
        self.firstLabel.alpha = 0.0;
    } completion:^(BOOL completion) {
        //[self animateCreditsWithCount:count+1];
    }];
}



@end
