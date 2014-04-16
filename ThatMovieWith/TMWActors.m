//
//  TMWActors.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/16/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWActors.h"

@interface TMWActors ()

@property (nonatomic) NSMutableArray *names;
@property (nonatomic) NSURLSession *session;
@property (nonatomic, retain) NSArray *actorResults;

@end

@implementation TMWActors

+ (instancetype)initializeActors
{
    static TMWActors *actors;
    
    // Do I need to create a session?
    if (!actors) {
        actors = [[self alloc] init];
    }
    
    return actors;
}

- (instancetype)init
{
    self = [super init];
    
    NSURLSessionConfiguration *config =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config
                                             delegate:nil
                                        delegateQueue:nil];
    self.names = [[NSMutableArray alloc] init];
    
    return self;
}

- (NSArray *)retrieveActorDataResultsForName:(NSString *)query
{
    NSURLRequest *req = [self setupURLRequestForActor:query];
    
    NSURLSessionDataTask *dataTask =
    [self.session dataTaskWithRequest:req
                    completionHandler:
     ^(NSData *data, NSURLResponse *response, NSError *error) {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:0
                                                                      error:nil];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.names removeAllObjects];
             
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

- (NSArray *)retrieveActorNameResultsForName:(NSString *)query
{
    NSURLRequest *req = [self setupURLRequestForActor:query];
    
    NSURLSessionDataTask *dataTask =
    [self.session dataTaskWithRequest:req
                    completionHandler:
     ^(NSData *data, NSURLResponse *response, NSError *error) {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:0
                                                                      error:nil];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.names removeAllObjects];
             
             int val = [[jsonObject objectForKey:@"total_results"] intValue];
             if (val != 0)
             {
                 self.actorResults = [[NSArray alloc] initWithArray:jsonObject[@"results"]];
                 NSLog(@"%@", self.actorResults);
                 
                 // Create an array of the names for the UITableView
                 for (NSDictionary *person in self.actorResults) {
                     [self.names addObject:person[@"name"]];
                 }
             }
         });
         
     }];
    [dataTask resume];
    return [NSArray arrayWithArray:self.names];
}

- (NSURLRequest *)setupURLRequestForActor:(NSString *)query
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"themoviedb" ofType:@""];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSLog(@"file exist");
    }
    else {
        NSLog(@"NO file exist");
    }
    NSString* contents = [NSString stringWithContentsOfFile:filePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    // Remove whitespace surrounding API key
    NSString *trimmedContents = [contents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *requestString = [[NSString stringWithFormat:@"https://api.themoviedb.org/3/search/person?search_type=ngram&query=%@&api_key=%@", query, trimmedContents] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    return req;
}

@end
