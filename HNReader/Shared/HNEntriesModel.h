//
//  HNEntriesModel.h
//  HNEntriesModel
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

@interface HNEntriesModel : NSObject

@property (nonatomic, copy) NSMutableArray *entries;
@property (nonatomic, copy) NSError *error;
@property (nonatomic, copy) NSString *moreEntriesLink;

- (NSUInteger)countOfEntries;
- (id)objectInEntriesAtIndex:(NSUInteger)index;
- (void)getEntriesObjects:(__unsafe_unretained id *)objects range:(NSRange)range;

- (void)loadEntriesForIndex:(NSUInteger)index;
- (void)reloadEntriesForIndex:(NSUInteger)index;

- (void)loadMoreEntriesForIndex:(NSUInteger)index;
- (void)loadEntriesForRequest:(NSURLRequest *)request atCachedFilePath:(NSString *)cachedFilePath;

- (NSString *)cacheFilePathForIndex:(NSUInteger)index;
- (NSURL *)pageURLForIndex:(NSUInteger)index;
- (int)cacheTimeForPageIndex:(NSUInteger)index;

- (NSError *)parserError;

@end
