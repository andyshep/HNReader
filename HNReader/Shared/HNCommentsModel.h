//
//  HNCommentsModel.h
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

@class HNEntry;

@interface HNCommentsModel : NSObject

@property (nonatomic, copy) NSMutableDictionary *commentsInfo;
@property (nonatomic, copy) NSError *error;
@property (nonatomic, strong) HNEntry *entry;

- (id)initWithEntry:(HNEntry *)entry;

- (void)cancelRequest;
- (void)loadComments;
- (void)loadCommentsForRequest:(NSURLRequest *)request;

@end
