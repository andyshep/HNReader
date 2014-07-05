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

#import "HNCacheManager.h"

@interface HNCommentsModel ()

@property (nonatomic, copy, readwrite) NSDictionary *comments;

- (NSString *)cacheFilePath;
- (NSOperationQueue *)operationQueue;

@end

@implementation HNCommentsModel

- (instancetype)initWithEntry:(HNEntry *)entry {
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
    
    NSString *commentId = [[_entry commentsPageURL] substringFromIndex:8];
    id cachedObj = [[HNCacheManager sharedManager] cachedCommentsForKey:commentId];
    if (cachedObj) {
        NSDictionary *comments = (NSDictionary *)cachedObj;
        self.comments = [NSDictionary dictionaryWithDictionary:comments];
    } else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:HNWebsitePlaceholderURL, [_entry commentsPageURL]]];
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
        NSString *commentId = [self.entry.commentsPageURL substringFromIndex:8];
        [[HNCacheManager sharedManager] cacheComments:comments forKey:commentId];
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
