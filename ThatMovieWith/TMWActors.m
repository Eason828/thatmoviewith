//
//  TMWActors.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/16/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWActors.h"

#define kAppIconSize 48

@interface TMWActors ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic, retain) NSArray *actorResults;
@property (nonatomic) NSString *baseURL;
@property (nonatomic) NSArray *logoSizes;
@property (nonatomic) NSArray *actorImages;

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
                 self.actorResults = [[NSArray alloc] initWithArray:jsonObject[@"results"]];
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

- (UIImage *)retriveActorImagesForActorDataResults:(NSString *)profilePath
{
    NSString *requestString = [[NSString stringWithFormat:@"%@/%@/%@", self.baseURL, [self.logoSizes objectAtIndex:1], profilePath]
                stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    if (profilePath != (id)[NSNull null])
    {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:requestString]]];
        if (image.size.width != kAppIconSize || image.size.height != kAppIconSize)
        {
            CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [image drawInRect:imageRect];
            //self.appRecord.appIcon = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return image;
        }
        else
        {
            return  image;
        }
    }
    else
    {
        return [UIImage imageNamed:@"Placeholder.png"];
    }
    
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

@end
