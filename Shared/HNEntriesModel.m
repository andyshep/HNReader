//
//  HNEntriesModel.m
//  HNEntriesModel
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNEntriesModel.h"

#import "HNClient.h"

#import "HNEntry.h"
#import "HNParser.h"
#import "HNCacheManager.h"

#import "HNConstants.h"

typedef NS_ENUM(NSInteger, HNEntriesPageIdentifier) {
    HNEntriesFrontPageIdentifier = 0,
    HNEntriesNewestPageIdentifier,
    HNEntriesBestPageIdentifier
};

@interface HNEntriesModel ()

@property (nonatomic, strong) HNClient *client;
@property (nonatomic, copy, readwrite) NSError *error;
@property (nonatomic, strong, readwrite) NSMutableArray *entries;

- (NSURL *)pageURLForIndex:(NSUInteger)index;
- (NSTimeInterval)cacheTimeForPageIndex:(NSUInteger)index;

@end

@implementation HNEntriesModel

- (instancetype)init {
    if ((self = [super init])) {
        self.moreEntriesLink = @"/news2";
        self.entries = [NSMutableArray array];
        self.client = [[HNClient alloc] init];
    }
    
    return self;
}

#pragma mark - Cache Management
+ (NSArray *)cacheKeys {
    static NSArray *_cacheKeys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cacheKeys = @[HNFrontPageKey, HNNewestPageKey, HNBestPageKey];
    });
    return _cacheKeys;
}

- (NSString *)cacheKeyForIndex:(NSUInteger)index {
    NSAssert(index <= 2, @"Cache Key index expected to be less than 2");
    NSString *key = [[HNEntriesModel cacheKeys] objectAtIndex:index];
    return key;
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
    NSString *key = [[[filePath lastPathComponent] componentsSeparatedByString:@"."] firstObject];
    return key;
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
    NSString *cacheKey = [self cacheKeyForIndex:index];
    NSURL *url = [self pageURLForIndex:index];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self loadEntriesForRequest:request withCacheKey:cacheKey];
}

- (void)loadMoreEntriesForIndex:(NSUInteger)index {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HNWebsiteBaseURL, self.moreEntriesLink]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // we can keep the old entries around if we're loading more
    NSString *cacheKey = [self cacheKeyForIndex:index];
    [self loadEntriesForRequest:request withCacheKey:cacheKey];
}

- (void)loadEntriesForRequest:(NSURLRequest *)request withCacheKey:(NSString *)cachedKey {
    [[self.client signalForRequest:request] subscribeNext:^(id response) {
        [self parseResponse:response withCacheKey:cachedKey];
    } error:^(NSError *error) {
        self.error = error;
    } completed:^{
        // no-op
    }];
}

- (void)parseResponse:(NSData *)response withCacheKey:(NSString *)cacheKey {
    NSDictionary *parsedResponse = [HNParser parsedEntriesFromResponse:response];
    
    NSArray *entries = [parsedResponse objectForKey:HNEntriesKey];
    [self willChangeValueForKey:HNEntriesKeyPath];
    [self.entries removeAllObjects];
    [self.entries addObjectsFromArray:[NSArray arrayWithArray:entries]];
    [self didChangeValueForKey:HNEntriesKeyPath];
    
    self.moreEntriesLink = [parsedResponse objectForKey:HNEntryNextKey];
    
    [[HNCacheManager sharedManager] cacheEntries:entries forKey:cacheKey];
}

@end
