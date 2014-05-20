//
//  TMWContainerViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 5/15/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWContainerViewController.h"
#import "TMWActorViewController.h"
#import "TMWAboutViewController.h"

#import "UIColor+customColors.h"
#import "CALayer+circleLayer.h"

#import <QuartzCore/QuartzCore.h>

@interface TMWContainerViewController ()

@property TMWAboutViewController *aboutViewController;
@property TMWActorViewController *actorViewController;
@property (nonatomic, copy) UIButton *infoButton;
@property (nonatomic, copy) UIButton *doneButton;

@end

@implementation TMWContainerViewController

- (void) loadView
{
    UIView *view = [UIView new];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
//    // Do any additional setup after loading the view.
    _actorViewController = [TMWActorViewController new];
    _aboutViewController = [TMWAboutViewController new];
    
    _actorViewController.view.frame = self.view.frame;
    _aboutViewController.view.frame = self.view.frame;
    [self addChildViewController:_actorViewController];
    [self addChildViewController:_aboutViewController];
    [self.view addSubview:_aboutViewController.view];
    [self.view addSubview:_actorViewController.view];
    
    // The info button to flip to the about view
    _infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    _infoButton.showsTouchWhenHighlighted = TRUE;
    [_infoButton setTintColor:[UIColor goldColor]];
    _infoButton.tag = 1;
    [_infoButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //[_actorViewController.view addSubview:_infoButton];
    
    // Add dropshadow to the info button
    [CALayer dropShadowLayer:_infoButton.layer];
    
    // Done button to flip back to the main view
    _doneButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    _doneButton.showsTouchWhenHighlighted = TRUE;
    [_doneButton setTintColor:[UIColor blueColor]];
    _doneButton.tag = 2;
    [_doneButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_aboutViewController.view addSubview:_doneButton];
    
    // To call perferredStatusBarStyle
    [self setNeedsStatusBarAppearanceUpdate];
}

// This is called after autolayout has set the views
- (void)viewDidLayoutSubviews
{
     _infoButton.center = CGPointMake(self.view.frame.size.width-32, self.view.frame.size.height-47);
    _doneButton.center = CGPointMake(self.view.frame.size.width-32, self.view.frame.size.height-47);
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(IBAction)buttonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch ([button tag]) {
        case 1: // Info button in actor view
        {
            [self flipFromViewController:_actorViewController toViewController:_aboutViewController withDirection:UIViewAnimationOptionTransitionFlipFromRight andDelay:0.0];

            break;
        }
        case 2: //Done button in about view
        {
            [self flipFromViewController:_aboutViewController toViewController:_actorViewController withDirection:UIViewAnimationOptionTransitionFlipFromRight andDelay:0.0];
            break;
        }

    }
}

- (void) flipFromViewController:(UIViewController*) fromController toViewController:(UIViewController*) toController  withDirection:(UIViewAnimationOptions) direction andDelay:(double) delay
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        toController.view.frame = fromController.view.bounds;
        [self addChildViewController:toController];
        [fromController willMoveToParentViewController:nil];
        
        [self transitionFromViewController:fromController
                          toViewController:toController
                                  duration:1.0
                                   options:direction | UIViewAnimationOptionCurveEaseIn
                                animations:nil
                                completion:^(BOOL finished) {
                                    
                                    [toController didMoveToParentViewController:self];
                                    [fromController removeFromParentViewController];
                                }];
    });
}


@end
