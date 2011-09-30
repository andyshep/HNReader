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

@interface HNReaderModel : NSObject {
    NSArray *entries;
    NSError *error;
}

@property (copy) NSArray *entries;
@property (copy) NSError *error;

- (NSUInteger)countOfEntries;
- (id)objectInEntriesAtIndex:(NSUInteger)index;
- (void)getEntriesObjects:(id *)objects range:(NSRange)range;

-(void)requestEntries;

@end
