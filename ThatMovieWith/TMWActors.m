//
//  TMWActors.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/16/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWActors.h"

@interface TMWActors ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSString *baseURL;
@property (nonatomic) NSArray *logoSizes;
@property (nonatomic, retain) NSArray *actorResults;

@end

@implementation TMWActors

#pragma mark - Public Methods -

- (instancetype)init
{
    self = [super init];
    
    NSURLSessionConfiguration *config =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config
                                             delegate:nil
                                        delegateQueue:nil];

    // Get the base URL and the image sizes
    NSString *apikey = [self retrieveAPIKey];
    NSString *requestString = [[NSString stringWithFormat:@"https://api.themoviedb.org/3/configuration?api_key=%@", apikey] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];

    NSURLSessionDataTask *dataTask =
    [self.session dataTaskWithRequest:req
                    completionHandler:
     ^(NSData *data, NSURLResponse *response, NSError *error) {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:0
                                                                      error:nil];
         
         dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *imagesObject = jsonObject[@"images"];
            self.baseURL = imagesObject[@"base_url"];
            self.logoSizes = imagesObject[@"logo_sizes"];
         });
         
     }];
    [dataTask resume];
    
    return self;
}

- (NSArray *)retrieveActorDataResultsForQuery:(NSString *)query
{
    NSURLRequest *req = [self setupURLRequestForActors:query];
    
    NSURLSessionDataTask *dataTask =
    [self.session dataTaskWithRequest:req
                    completionHandler:
     ^(NSData *data, NSURLResponse *response, NSError *error) {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:0
                                                                      error:nil];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             int val = [[jsonObject objectForKey:@"total_results"] intValue];
             if (val != 0)
             {
                 NSArray *unfilteredActorResults = [[NSArray alloc] initWithArray:jsonObject[@"results"]];
                 NSMutableArray *filteredActorResults = [[NSMutableArray alloc] initWithArray:unfilteredActorResults];

                 for (NSDictionary *actor in unfilteredActorResults)
                 {
                     if (actor[@"profile_path"] != (id)[NSNull null])
                     {
                         [filteredActorResults addObject:actor];
                     }
                 }
                 self.actorResults = filteredActorResults;
             }
         });
         
     }];
    [dataTask resume];
    return self.actorResults;
}

- (NSArray *)retrieveActorNamesForActorDataResults:(NSArray *)dataResults
{
    NSMutableArray *names = [[NSMutableArray alloc] init];
    // Create an array of the names for the UITableView
    for (NSDictionary *person in dataResults) {
        [names addObject:person[@"name"]];
    }
    return [NSArray arrayWithArray:names];
}

// TODO: Configure image size as a parameter so that thumbs are smaller
// Note: this returns and array of NSStrings mixed with UIImages 
- (NSArray *)retriveActorImagesForActorDataResults:(NSArray *)dataResults
{
    NSMutableArray *URLArray = [[NSMutableArray alloc] init];
    for (NSDictionary *actor in dataResults)
    {
        if (actor[@"profile_path"] != (id)[NSNull null])
        {
            NSString *requestString = [[NSString stringWithFormat:@"%@%@%@", self.baseURL, [self.logoSizes objectAtIndex:4], actor[@"profile_path"]]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            [URLArray addObject:requestString];
        }
        else
        {
            // TODO: Make this a 1 px png or clear image
            UIImage *defaultImage = [self imageByDrawingInitialsOnImage:[UIImage imageNamed:@"Placeholder.png"] 
                                            withInitials:actor[@"name"]];
            [URLArray addObject:defaultImage];
        }
    }
    return [NSArray arrayWithArray:URLArray];
    
}

#pragma mark - Private Methods -

- (NSString *)retrieveAPIKey
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"themoviedb" ofType:@""];

    NSString *contents = [NSString stringWithContentsOfFile:filePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
    // Remove whitespace surrounding API key
    return [contents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

}

- (NSURLRequest *)setupURLRequestForActors:(NSString *)query
{
    NSString *contents = [self retrieveAPIKey];

    NSString *requestString = [[NSString stringWithFormat:@"https://api.themoviedb.org/3/search/person?search_type=ngram&query=%@&api_key=%@", query, contents] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    return req;
}

- (UIImage *)imageByDrawingInitialsOnImage:(UIImage *)image withInitials:(NSString *)initials
{
    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContext(image.size);
 
    // draw original image into the context
    [image drawAtPoint:CGPointZero];
 
    // get the context for CoreGraphics
    UIGraphicsGetCurrentContext();

    NSArray *separatedNames = [initials componentsSeparatedByString:@" "];
    
    if ([separatedNames count] > 0) {
        NSMutableString *combinedInitials = [[NSMutableString alloc] initWithString:[separatedNames[0] substringToIndex:1]]; 
        if ([separatedNames count] > 1) {
            [combinedInitials appendString:[separatedNames[1] substringToIndex:1]];
        }

        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByWordWrapping;
        textStyle.alignment = NSTextAlignmentCenter;
        UIFont *textFont = [UIFont systemFontOfSize:16];

        NSDictionary *attributes = @{NSFontAttributeName: textFont};
        
        // Create the CGRect to the size of the text box
        CGSize size = [combinedInitials sizeWithAttributes:attributes];
        if (size.width < image.size.width)
        {
            CGRect textRect = CGRectMake(0, 
                              (image.size.height - size.height)/2, 
                              image.size.width, 
                              (image.size.height - size.height));

            [combinedInitials drawInRect:textRect withAttributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle}];
        }
    }
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
 
    // free the context
    UIGraphicsEndImageContext();
 
    return retImage;
}

@end
