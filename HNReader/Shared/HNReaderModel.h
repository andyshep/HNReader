//
//  HNReaderModel.h
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "HNEntry.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

typedef enum  {
    HNEntriesFrontPageIdentifier,
    HNEntriesNewestPageIdentifier,
    HNEntriesBestPageIdentifier
} HNEntriesPageIdentifier;

@interface HNReaderModel : NSObject {
    NSMutableArray *entries;
    NSError *error;
    NSString *moreEntriesLink;
    
    NSOperationQueue *opQueue;
}

@property (copy) NSMutableArray *entries;
@property (copy) NSError *error;
@property (copy) NSString *moreEntriesLink;

- (NSUInteger)countOfEntries;
- (id)objectInEntriesAtIndex:(NSUInteger)index;
- (void)getEntriesObjects:(id *)objects range:(NSRange)range;

- (void)loadEntriesForIndex:(NSUInteger)index;
- (void)loadMoreEntries;
- (void)loadEntriesForRequest:(NSURLRequest *)request;

- (NSError *)parserError;

@end
