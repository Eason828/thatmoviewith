//
//  SVWebViewControllerActivityIMDB.m
//  ThatMovieWith
//
//  Created by johnrhickey on 5/5/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "SVWebViewControllerActivityIMDB.h"

@implementation SVWebViewControllerActivityIMDB

- (NSString *)schemePrefix {
    return @"imdb:///";
}

- (NSString *)activityTitle {
	return NSLocalizedStringFromTable(@"Open in IMDB", @"SVWebViewController", nil);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.schemePrefix]]) {
			return YES;
		}
	}
	return NO;
}

- (void)performActivity {
    NSString *openingURL = [self.URLToOpen.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString* imdbID = [[openingURL lastPathComponent] stringByDeletingPathExtension];
    
    NSURL *activityURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@title/%@", self.schemePrefix, imdbID]];
	[[UIApplication sharedApplication] openURL:activityURL];
    
	[self activityDidFinish:YES];
}

@end
