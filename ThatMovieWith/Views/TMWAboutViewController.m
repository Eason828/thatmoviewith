//
//  TMWInfoViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 5/15/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <sys/utsname.h>

#import "TMWAboutViewController.h"
#import "TMWAutoScroll.h"
#import "SVWebViewController.h"
#import "UIColor+customColors.h"

@interface TMWAboutViewController () <UIScrollViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *creditsScrollView;
@property (nonatomic, retain) IBOutlet UIView *endView;
@property (nonatomic, retain) IBOutlet UILabel *buildLabel;

@end

@implementation TMWAboutViewController

NSString *version;
NSString *buildNumber;

static bool webButtonPressed;

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollToTop:)
                                                 name:@"scrollToTop"
                                               object:nil];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Get the version info
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    buildNumber = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    _buildLabel.text = [NSString stringWithFormat:@"Build %@ (%@)",
                        version, buildNumber];
    
    
    // Setup the auto scrolling
    _creditsScrollView.scrollPointsPerSecond = 30.0f;
    [_creditsScrollView startScrolling];
    
    [_creditsScrollView setScrollsToTop:NO];
    [_creditsScrollView setShowsVerticalScrollIndicator:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playBackgroundMusic" object:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIView beginAnimations:@"showStatusBar" context:nil];
    [UIView setAnimationDuration:0.0];
    if (webButtonPressed == NO) [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [UIView commitAnimations];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
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

- (void)scrollToTop:(NSNotification *)notification
{
    // Bring the scroll view back to the top
    [_creditsScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)addInfoButton
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"addInfoButton"
     object:self];
}

-(IBAction)buttonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    webButtonPressed = YES;
    
    // Restart the scrolling credits in the About view
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseBackgroundMusic" object:self];
    
    switch ([button tag]) {
        case 1: // First actor button
        {
            SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:@"http://twitter.com/jayhickey"];
            webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
            webViewController.barsTintColor = [UIColor goldColor];
            [_creditsScrollView stopScrolling];
            [self presentViewController:webViewController animated:YES completion:^(){
                webButtonPressed = NO;
                [self.creditsScrollView startScrolling];
            }];
            break;
        }
            
        case 2: // Second actor button
        {
            if ([MFMailComposeViewController canSendMail]) {
                [_creditsScrollView stopScrolling];
                MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                [composeViewController setMailComposeDelegate:self];
                [composeViewController setToRecipients:@[@"support@thatmoviewith.com"]];
                [composeViewController setSubject:@"That Movie With"];
                
                struct utsname systemInfo;
                uname(&systemInfo);
                NSString *msgBody = [NSString stringWithFormat:@"\n\n\n------\nDevice: %@\niOS: %@\nVersion: %@ (%@)", [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding], [[UIDevice currentDevice] systemVersion], version, buildNumber];
                [composeViewController setMessageBody:msgBody isHTML:NO];
                [self presentViewController:composeViewController animated:YES completion:^(){
                    webButtonPressed = NO;
                    [self.creditsScrollView startScrolling];
                }];
            }
            break;
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // you can test the result of the mail sending here if you want
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
