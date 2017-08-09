//
//  HNCommentsParser.h
//  HNReader iOS
//
//  Created by Andrew Shepard on 7/26/17.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HNCommentsParserState) {
    HNCommentsParserStateIdle = 100,
    HNCommentsParserStateSearchForTree,
    HNCommentsParserStateSearchForIndent,
    HNCommentsParserStateSearchForUser,
    HNCommentsParserStateLoadUser,
    HNCommentsParserStateSearchForAge,
    HNCommentsParserStateLoadAge,
    HNCommentsParserStateSearchForComment,
    HNCommentsParserStateLoadComment
};

@class HNComment;

@interface HNCommentsParser : NSObject

@property (nonatomic, assign, readonly) HNCommentsParserState state;
@property (nullable, nonatomic, strong) HNComment *current;

- (nullable instancetype)initWithData:(nonnull NSData *)data;

- (nonnull NSArray<HNComment *> *)parseComments;
- (void)nextState;

@end
