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

@import AVFoundation;

@interface TMWContainerViewController () <AVAudioPlayerDelegate>

@property TMWAboutViewController *aboutViewController;
@property TMWActorViewController *actorViewController;
@property (nonatomic, copy) UIButton *doneButton;
@property (nonatomic, copy) UIButton *infoButton;
@property (nonatomic, copy) UIBarButtonItem *doneBarButtonItem;
@property (nonatomic, copy) UIBarButtonItem *soundButtonItem;
@property (strong, nonatomic, getter=theBackgroundPlayer) AVAudioPlayer *backgroundPlayer;

@end

@implementation TMWContainerViewController

- (void)loadView
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseBackgroundMusic:)
                                                 name:@"pauseBackgroundMusic"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playBackgroundMusic:)
                                                 name:@"playBackgroundMusic"
                                               object:nil];
    
    _doneBarButtonItem = [UIBarButtonItem new];
    _doneBarButtonItem.title = @"Done";
    _doneBarButtonItem.tintColor = [UIColor goldColor];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = _doneBarButtonItem;
    
    _soundButtonItem = [UIBarButtonItem new];
    self.navigationController.navigationBar.topItem.rightBarButtonItem = _soundButtonItem;
    _soundButtonItem.tintColor = [UIColor goldColor];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SoundsEnabled"] == YES) {
        _soundButtonItem.image = [UIImage imageNamed:@"audio-mute"];
    }
    else {
        _soundButtonItem.image = [UIImage imageNamed:@"audio-high"];
    }
    
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"buttonRoundedDeleteHighlighted"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"buttonRoundedDeleteHighlighted"]];
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
    
    // For toggling the sounds
    _soundButtonItem.tag = 3;
    [_soundButtonItem setTarget:self];
    [_soundButtonItem setAction:@selector(buttonPressed:)];
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
    [self.view bringSubviewToFront:_infoButton];
    [self.view setNeedsLayout];
}

- (void)pauseBackgroundMusic:(NSNotification *)notification
{
    [self doVolumeFadeOutAndRestartToTime:[NSNumber numberWithDouble:_backgroundPlayer.currentTime]];
}

- (void)playBackgroundMusic:(NSNotification *)notification
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SoundsEnabled"] == YES) {
        _backgroundPlayer.volume = 0.0;
        [_backgroundPlayer play];
        [self doVolumeFadeIn];
    }
}

-(void)doVolumeFadeOutAndRestartToTime:(NSNumber *)currentTime
{
    if (_backgroundPlayer.volume > 0.1) {
        _backgroundPlayer.volume = _backgroundPlayer.volume - 0.05;
        [self performSelector:@selector(doVolumeFadeOutAndRestartToTime:) withObject:currentTime afterDelay:0.05];
    } else {
        // Stop and get the sound ready for playing again
        [_backgroundPlayer stop];
        _backgroundPlayer.currentTime = [currentTime doubleValue];
        [_backgroundPlayer prepareToPlay];
    }
}

-(void)doVolumeFadeIn
{
    
    if (_backgroundPlayer.volume < 1.0) {
        _backgroundPlayer.volume = _backgroundPlayer.volume + 0.04;
        [self performSelector:@selector(doVolumeFadeIn) withObject:nil afterDelay:0.1];
    }
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
            [[UIApplication sharedApplication] setStatusBarHidden:NO];

            NSDictionary *soundDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Sounds" ofType:@"plist"]];
            NSString *soundFilePath  = [[NSBundle mainBundle] pathForResource:soundDictionary[@"Credits Background Music"] ofType:@"m4a"];
            NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
            _backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
            _backgroundPlayer.numberOfLoops = -1; //infinite
        
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SoundsEnabled"] == YES) {
                _backgroundPlayer.volume = 0.0;
                [_backgroundPlayer play];
                [self doVolumeFadeIn];
            }
            
            // Restart the scrolling credits in the About view
            [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollToTop" object:self];
            
            break;
        }
        case 2: //Done button in about view
        {
            [self flipFromViewController:_aboutViewController toViewController:_actorViewController withDirection:UIViewAnimationOptionTransitionFlipFromLeft andDelay:0.0];
            _infoButton.hidden = NO;
            [self doVolumeFadeOutAndRestartToTime:0];
            break;
        }
        case 3:
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SoundsEnabled"] == YES) {
                _soundButtonItem.image = [UIImage imageNamed:@"audio-high"];
                [self.view setNeedsDisplay];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SoundsEnabled"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self doVolumeFadeOutAndRestartToTime:0];
                //_backgroundPlayer.currentTime = 0;
            }
            else {
                _soundButtonItem.image = [UIImage imageNamed:@"audio-mute"];
                [self.view setNeedsDisplay];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SoundsEnabled"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                _backgroundPlayer.volume = 0.0;
                [_backgroundPlayer play];
                [self doVolumeFadeIn];
            }
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
