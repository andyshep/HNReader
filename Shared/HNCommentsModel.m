//
//  HNCommentsModel.m
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNCommentsModel.h"
#import "HNConstants.h"

#import "HNCommentsParser.h"
#import "HNEntry.h"
#import "HNComment.h"

#import "HNClient.h"
#import "HNCacheManager.h"

@interface HNCommentsModel ()

@property (nonatomic, strong) HNClient *client;
@property (nonatomic, copy, readwrite) NSArray<HNComment *> *comments;

@end

@implementation HNCommentsModel

- (instancetype)initWithEntry:(HNEntry *)entry {
    if ((self = [super init])) {
        self.entry = entry;
        self.client = [[HNClient alloc] init];
    }
    
    return self;
}

#pragma mark - Cache Management
- (void)loadComments {
//    NSString *commentId = [self.entry.commentsPageURL substringFromIndex:8];
//    id cachedObj = [[HNCacheManager sharedManager] cachedCommentsForKey:commentId];
//    if (cachedObj) {
//        NSDictionary *comments = (NSDictionary *)cachedObj;
//        self.comments = [NSDictionary dictionaryWithDictionary:comments];
//    } else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:HNWebsitePlaceholderURL, self.entry.commentsPageURL]];
        [self loadCommentsForRequest:[NSURLRequest requestWithURL:url]];
//    }
}

- (void)loadCommentsForRequest:(NSURLRequest *)request {
    
    [[self.client taskForURLRequest:request success:^(id response) {
        HNCommentsParser *parser = [[HNCommentsParser alloc] initWithData:response];
        NSArray *comments = [parser parseComments];
        
        self.comments = comments;
//        NSString *commentId = [self.entry.commentsPageURL substringFromIndex:8];
//        [[HNCacheManager sharedManager] cacheComments:comments forKey:commentId];
    } error:^(NSError *error) {
        self.error = error;
    }] resume];
}

@end
