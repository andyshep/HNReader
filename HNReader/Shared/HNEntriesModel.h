//
//  HNEntriesModel.h
//  HNEntriesModel
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

@interface HNEntriesModel : NSObject

@property (nonatomic, copy) NSError *error;
@property (nonatomic, copy) NSString *moreEntriesLink;

- (void)loadEntriesForIndex:(NSUInteger)index;
- (void)reloadEntriesForIndex:(NSUInteger)index;

- (void)loadMoreEntriesForIndex:(NSUInteger)index;
- (void)loadEntriesForRequest:(NSURLRequest *)request atCachedFilePath:(NSString *)cachedFilePath;

@end

@interface HNEntriesModel (HNCollections)

@property (nonatomic, strong, readonly) NSArray *entries;

@end
