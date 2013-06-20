//
//  HNCommentsModel.h
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "HNEntry.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

#import "HNComment.h"
#import "HNEntry.h"

#import "NSString+Tags.h"
#import "NSString+Entities.h"

@interface HNCommentsModel : NSObject {
    NSMutableDictionary *commentsInfo;
    NSError *error;
    
    NSOperationQueue *opQueue;
    HNEntry *entry;
}

@property (copy) NSMutableDictionary *commentsInfo;
@property (copy) NSError *error;
@property (nonatomic, strong) HNEntry *entry;

- (id)initWithEntry:(HNEntry *)aEntry;
- (void)loadComments;
- (void)loadCommentsForRequest:(NSURLRequest *)request;
- (NSString *)cacheFilePath;

- (NSString *)formatCommentText:(NSString *)commentText;

- (void)cancelRequest;

@end
