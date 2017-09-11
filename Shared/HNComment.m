//
//  HNComment.m
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNComment.h"

@implementation HNComment

- (instancetype)init {
    if (self = [super init]) {
        self.padding = 0;
        self.commentString = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.timeSinceCreation = [aDecoder decodeObjectForKey:@"timeSinceCreation"];
        self.commentString = [aDecoder decodeObjectForKey:@"commentString"];
        self.padding = [aDecoder decodeIntegerForKey:@"padding"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.timeSinceCreation forKey:@"timeSinceCreation"];
    [aCoder encodeObject:self.commentString forKey:@"commentString"];
    [aCoder encodeInteger:self.padding forKey:@"padding"];
}

- (NSUInteger)hash {
    return self.commentString.hash;
}

- (BOOL)isEqual:(HNComment *)comment {
    if (![comment isKindOfClass:[HNComment class]]) {
        return NO;
    }
    
    BOOL equal = [self.commentString isEqualToString:comment.commentString] && [self.username isEqualToString:self.username];
    return equal;
}

@end
