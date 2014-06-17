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

#import <QuartzCore/QuartzCore.h>

@interface TMWContainerViewController ()

@property TMWAboutViewController *aboutViewController;
@property TMWActorViewController *actorViewController;
@property (nonatomic, copy) UIButton *doneButton;
@property (nonatomic, copy) UIButton *infoButton;
@property (nonatomic, copy) UIBarButtonItem *doneBarButtonItem;

@end

@implementation TMWContainerViewController

- (void) loadView
{
    UIView *view = [UIView new];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = view;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeInfoButton:)
                                                 name:@"removeInfoButton"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addInfoButton:)
                                                 name:@"addInfoButton"
                                               object:nil];
    _doneBarButtonItem = [UIBarButtonItem new];
    _doneBarButtonItem.title = @"Done";
    _doneBarButtonItem.tintColor = [UIColor blueColor];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = _doneBarButtonItem;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
    [_infoButton setTintColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
    _infoButton.tag = 1;
    [_infoButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_actorViewController.view addSubview:_infoButton];
    [self addInfoButton:[NSNotification notificationWithName:@"addInfoButton" object:self]];
    
    // Done button to flip back to the main view
    _doneBarButtonItem.tag = 2;
    [_doneBarButtonItem setTarget:self];
    [_doneBarButtonItem setAction:@selector(buttonPressed:)];
}

- (void)removeInfoButton:(NSNotification *)notification
{
    [_infoButton removeFromSuperview];
    [self.view setNeedsLayout];
}

- (void)addInfoButton:(NSNotification *)notification
{
    [self.view addSubview:_infoButton];
    _infoButton.alpha = 0.0;
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         self.infoButton.alpha = 0.75;
                     }
                     completion:nil];
}

// This is called after autolayout has set the views
- (void)viewDidLayoutSubviews
{
     _infoButton.center = CGPointMake(self.view.frame.size.width-32, self.view.frame.size.height-32);
}


-(IBAction)buttonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch ([button tag]) {
        case 1: // Info button in actor view
        {
            [self flipFromViewController:_actorViewController toViewController:_aboutViewController withDirection:UIViewAnimationOptionTransitionFlipFromRight andDelay:0.0];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            _infoButton.hidden = YES;
            self.navigationController.navigationBar.topItem.title = @"";

            break;
        }
        case 2: //Done button in about view
        {
            [self flipFromViewController:_aboutViewController toViewController:_actorViewController withDirection:UIViewAnimationOptionTransitionFlipFromLeft andDelay:0.0];
            _infoButton.hidden = NO;
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
                                  duration:0.5
                                   options:direction | UIViewAnimationOptionCurveEaseIn
                                animations:nil
                                completion:^(BOOL finished) {
                                    
                                    [toController didMoveToParentViewController:self];
                                    [fromController removeFromParentViewController];
                                }];
    });
}


@end
