//
//  HNEntriesModel.h
//  HNEntriesModel
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNEntriesModel : NSObject

@property (nonatomic, copy, readonly) NSError *error;
@property (nonatomic, copy) NSString *moreEntriesLink;

- (void)loadEntriesForIndex:(NSUInteger)index;
- (void)reloadEntriesForIndex:(NSUInteger)index;

- (void)loadMoreEntriesForIndex:(NSUInteger)index;
- (void)loadEntriesForRequest:(NSURLRequest *)request withCacheKey:(NSString *)cachedKey;

@end

@interface HNEntriesModel (HNCollections)

@property (nonatomic, strong, readonly) NSArray *entries;

@end