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
    self.firstLabel = [UILabel new];
    self.firstLabel.frame = self.view.frame;
    self.firstLabel.textAlignment = NSTextAlignmentCenter;
    self.firstLabel.numberOfLines = 2;
    //self.firstLabel.text = @"Directed by\nJay Hickey";
    UIFont* broadwayFont = [UIFont systemFontOfSize:30];
    self.firstLabel.font = broadwayFont;
    self.firstLabel.alpha = 0;
    self.firstLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.firstLabel];
}

// TODO: Use NSNotificationCenter to alert when this
// view enters the foreground in the container view
- (void)viewDidAppear:(BOOL)animated
{
    creditsLength = 0;
    creditText = @[@"Directed by\nJay Hickey", @"Produced by\nJay Hickey",
                   @"Beta Testers\n"];
    
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
    NSLog(@"%i", count);
    if(count > creditText.count-1) {
        count = 0;
    }

    self.firstLabel.text = creditText[count];
    
    self.firstLabel.alpha = 1.0;
    
    [UIView animateWithDuration:0 delay:3.0 options:0 animations:^{
        self.firstLabel.alpha = 0.0;
    } completion:^(BOOL completion) {
        //[self animateCreditsWithCount:count+1];
    }];
}



@end
