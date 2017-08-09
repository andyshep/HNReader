//
//  HNParser.h
//  HNReader
//
//  Created by Andrew Shepard on 1/31/14.
//  Copyright 2014 Andrew Shepard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HNEntriesParserState) {
    HNEntriesParserStateIdle = 100,
    HNEntriesParserStateSearchForEntry,
    HNEntriesParserStateSearchForStoryLink,
    HNEntriesParserStateSearchForDomainURL,
    HNEntriesParserStateLoadDomainURL,
    HNEntriesParserStateSearchForSubtext,
    HNEntriesParserStateSearchForCommentAnchor,
    HNEntriesParserStateSearchForCommentCount
};

@class HNEntry;

@interface HNEntriesParser : NSObject

@property (nullable, nonatomic, strong) HNEntry *current;
@property (nonatomic, assign, readonly) HNEntriesParserState state;

- (nullable instancetype)initWithData:(nonnull NSData *)data;

- (void)nextState;
- (void)terminate;

- (nonnull NSArray<HNEntry *> *)parseEntries;

@end
