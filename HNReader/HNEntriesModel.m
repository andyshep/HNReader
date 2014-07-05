//
//  HNEntriesModel.m
//  HNEntriesModel
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNEntriesModel.h"

#import "AFHTTPRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFHTTPRequestOperationManager+HNReactiveExtension.h"

#import "HNEntry.h"
#import "HNParser.h"
#import "HNCacheManager.h"

#import "HNConstants.h"

typedef NS_ENUM(NSInteger, HNEntriesPageIdentifier) {
    HNEntriesFrontPageIdentifier,
    HNEntriesNewestPageIdentifier,
    HNEntriesBestPageIdentifier
};

@interface HNEntriesModel ()

@property (nonatomic, copy, readwrite) NSError *error;
@property (nonatomic, strong, readwrite) NSMutableArray *entries;

- (NSString *)cacheFilePathForIndex:(NSUInteger)index;
- (NSURL *)pageURLForIndex:(NSUInteger)index;
- (NSTimeInterval)cacheTimeForPageIndex:(NSUInteger)index;
- (NSOperationQueue *)operationQueue;

@end

@implementation HNEntriesModel

- (instancetype)init {
    if ((self = [super init])) {
        self.moreEntriesLink = @"/news2";
        self.entries = [NSMutableArray array];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    }
    
    return self;
}

#pragma mark - Cache Management
- (NSString *)cacheFilePathForIndex:(NSUInteger)index {
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    if (index == HNEntriesFrontPageIdentifier) {
        return [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"front.plist"]];
    } else if (index == HNEntriesBestPageIdentifier) {
        return [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"best.plist"]];
    } else {
        return [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"newest.plist"]];
    }
}

- (NSURL *)pageURLForIndex:(NSUInteger)index {
    if (index == HNEntriesFrontPageIdentifier) {
        return [NSURL URLWithString:HNWebsiteBaseURL];
    } else if (index == HNEntriesBestPageIdentifier) {
        return [NSURL URLWithString:[NSString stringWithFormat:HNWebsitePlaceholderURL, HNBestPageKey]];
    } else {
        return [NSURL URLWithString:[NSString stringWithFormat:HNWebsitePlaceholderURL, HNNewestPageKey]];
    }
}

- (NSString *)cacheKeyForPageIdentifier:(HNEntriesPageIdentifier)identifier {
    if (identifier == HNEntriesFrontPageIdentifier) {
        return HNFrontPageKey;
    } else if (identifier == HNEntriesNewestPageIdentifier) {
        return HNNewestPageKey;
    } else if (identifier == HNEntriesBestPageIdentifier) {
        return HNBestPageKey;
    } else {
        return nil;
    }
}

- (NSString *)cacheKeyForFilePath:(NSString *)filePath {
    return [[[filePath lastPathComponent] componentsSeparatedByString:@"."] firstObject];
}

- (NSTimeInterval)cacheTimeForPageIndex:(NSUInteger)index {
    if (index == HNEntriesNewestPageIdentifier) {
        return 60.0f;
    } else if (index == HNEntriesBestPageIdentifier) {
        return 7200.0f;
    } else {
        return 180.0f;
    }
}

#pragma mark - Network Requests
- (void)loadEntriesForIndex:(NSUInteger)index {
    if (self.entries.count > 0) {
        [self willChangeValueForKey:HNEntriesKeyPath];
        [self.entries removeAllObjects];
        [self didChangeValueForKey:HNEntriesKeyPath];
    }
    
    NSString *key = [self cacheKeyForPageIdentifier:index];
    id cachedObj = [[HNCacheManager sharedManager] cachedEntriesForKey:key];
    if (cachedObj && [cachedObj isKindOfClass:[NSArray class]]) {
        NSArray *entries = (NSArray *)cachedObj;
        [self willChangeValueForKey:HNEntriesKeyPath];
        [self.entries removeAllObjects];
        [self.entries addObjectsFromArray:entries];
        [self didChangeValueForKey:HNEntriesKeyPath];
    } else {
        [self reloadEntriesForIndex:index];
    }
}

- (void)reloadEntriesForIndex:(NSUInteger)index {
    NSString *filePath = [self cacheFilePathForIndex:index];
    NSURL *url = [self pageURLForIndex:index];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self loadEntriesForRequest:request atCachedFilePath:filePath];
}

- (void)loadMoreEntriesForIndex:(NSUInteger)index {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HNWebsiteBaseURL, self.moreEntriesLink]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // we can keep the old entries around if we're loading more
    NSString *cachedFilePath = [self cacheFilePathForIndex:index];
    [self loadEntriesForRequest:request atCachedFilePath:cachedFilePath];
}

- (void)loadEntriesForRequest:(NSURLRequest *)request atCachedFilePath:(NSString *)cachedFilePath {
    @weakify(self);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [[manager signalForRequest:request] subscribeNext:^(AFHTTPRequestOperation *operation) {
        @strongify(self);
        [self parseResponse:operation.responseData withCachedFilePath:cachedFilePath];
    } error:^(NSError *err) {
        @strongify(self);
        self.error = err;
    } completed:^{
        //
    }];
    
    [manager signalForRequest:request];
}

- (void)parseResponse:(NSData *)response withCachedFilePath:(NSString *)cachedFilePath {
    NSDictionary *parsedResponse = [HNParser parsedEntriesFromResponse:response];
    
    NSArray *entries = [parsedResponse objectForKey:HNEntriesKey];
    [self willChangeValueForKey:HNEntriesKeyPath];
    [self.entries removeAllObjects];
    [self.entries addObjectsFromArray:[NSArray arrayWithArray:entries]];
    [self didChangeValueForKey:HNEntriesKeyPath];
    
    self.moreEntriesLink = [parsedResponse objectForKey:HNEntryNextKey];
    
    NSString *key = [self cacheKeyForFilePath:cachedFilePath];
    [[HNCacheManager sharedManager] cacheEntries:entries forKey:key];
}

- (NSOperationQueue *)operationQueue {
    return [[AFHTTPRequestOperationManager manager] operationQueue];
}

@end
