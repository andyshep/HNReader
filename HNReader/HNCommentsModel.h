//
//  HNCommentsModel.h
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

@class HNEntry;

@interface HNCommentsModel : NSObject

@property (nonatomic, copy, readonly) NSDictionary *comments;
@property (nonatomic, copy) NSError *error;
@property (nonatomic, strong) HNEntry *entry;

- (instancetype)initWithEntry:(HNEntry *)entry;

- (void)loadComments;
- (void)loadCommentsForRequest:(NSURLRequest *)request;

@end
