//
//  HNCommentsModel.m
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNCommentsModel.h"

#import "HNParser.h"
#import "HNEntry.h"
#import "HNComment.h"

@interface HNCommentsModel ()

@property (nonatomic, copy, readwrite) NSDictionary *comments;

- (NSString *)cacheFilePath;
- (NSOperationQueue *)operationQueue;

@end

@implementation HNCommentsModel

- (id)initWithEntry:(HNEntry *)entry {
    if ((self = [super init])) {
        self.entry = entry;
    }
    
    return self;
}

#pragma mark - Cache Management
- (NSString *)cacheFilePath {
    NSString *commentId = [[_entry commentsPageURL] substringFromIndex:8];
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cacheFilePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"comments_%@.plist", commentId]];
    
    return cacheFilePath;
}

- (void)loadComments {
    // determine if the cache is valid
    NSString *filePath = [self cacheFilePath];
    NSError *err;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:&err];
    if (attrs != nil && [attrs count] > 0) {
        // alway load from cache first
        NSDictionary *cachedComments = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        self.comments = [NSDictionary dictionaryWithDictionary:cachedComments];
        
        NSDate *date = [attrs valueForKey:@"NSFileModificationDate"];
        if (date != nil) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
            if (interval > 120.0f) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://news.ycombinator.com/%@", [_entry commentsPageURL]]];
                [self loadCommentsForRequest:[NSURLRequest requestWithURL:url]];
            }
        }
    } else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://news.ycombinator.com/%@", [_entry commentsPageURL]]];
        [self loadCommentsForRequest:[NSURLRequest requestWithURL:url]];
    }
}

-(void)loadCommentsForRequest:(NSURLRequest *)request {
    @weakify(self);
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSDictionary *comments = [HNParser parsedCommentsFromResponse:responseObject];
        self.comments = [NSDictionary dictionaryWithDictionary:comments];
        [NSKeyedArchiver archiveRootObject:self.comments toFile:[self cacheFilePath]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
        @strongify(self);
        self.error = err;
    }];
    
    [[self operationQueue] addOperation:operation];
}

- (NSOperationQueue *)operationQueue {
    return [[AFHTTPRequestOperationManager manager] operationQueue];
}

@end
