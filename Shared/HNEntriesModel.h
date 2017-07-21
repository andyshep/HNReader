//
//  HNEntriesModel.h
//  HNEntriesModel
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNEntriesModel : NSObject

@property (nullable, nonatomic, copy, readonly) NSError *error;
@property (nullable, nonatomic, copy) NSString *moreEntriesLink;

- (void)loadEntriesForIndex:(NSUInteger)index;
- (void)reloadEntriesForIndex:(NSUInteger)index;

- (void)loadMoreEntriesForIndex:(NSUInteger)index;
- (void)loadEntriesForRequest:(nonnull NSURLRequest *)request withCacheKey:(nonnull NSString *)cachedKey;

@end

@interface HNEntriesModel (HNCollections)

@property (nonnull, nonatomic, strong, readonly) NSArray *entries;

@end
