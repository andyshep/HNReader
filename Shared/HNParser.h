//
//  HNParser.h
//  HNReader
//
//  Created by Andrew Shepard on 1/31/14.
//  Copyright 2014 Andrew Shepard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HNParserParserState) {
    HNParserParserStateIdle = 100,
    HNParserParserStateSearchForEntry,
    HNParserParserStateSearchForStoryLink
};

@class HNEntry;

@interface HNParser : NSObject

@property (nullable, nonatomic, strong) HNEntry *current;
@property (nonatomic, assign, readonly) HNParserParserState state;

- (nullable instancetype)initWithData:(nonnull NSData *)data;

- (void)nextState;
- (void)terminate;

- (nonnull NSArray<HNEntry *> *)parseEntries;

@end
