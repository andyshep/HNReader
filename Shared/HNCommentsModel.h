//
//  HNCommentsModel.h
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HNEntry;
@class HNComment;

@interface HNCommentsModel : NSObject

@property (nonnull, nonatomic, copy, readonly) NSArray<HNComment *> *comments;
@property (nonnull, nonatomic, copy) NSError *error;
@property (nonnull, nonatomic, strong) HNEntry *entry;

- (nonnull instancetype)initWithEntry:(nonnull HNEntry *)entry;

- (void)loadComments;
- (void)loadCommentsForRequest:(nonnull NSURLRequest *)request;

@end
