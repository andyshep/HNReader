//
//  HNComment.m
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNComment.h"

@implementation HNComment

- (id)init {
    if ((self = [super init])) {
        self.username = nil;
        self.commentString = nil;
        self.timeSinceCreation = nil;
        self.padding = 0;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.commentString = [aDecoder decodeObjectForKey:@"commentString"];
        self.timeSinceCreation = [aDecoder decodeObjectForKey:@"timeSinceCreation"];
        self.padding = [aDecoder decodeIntegerForKey:@"padding"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.commentString forKey:@"commentString"];
    [aCoder encodeObject:self.timeSinceCreation forKey:@"timeSinceCreation"];
    [aCoder encodeInteger:self.padding forKey:@"padding"];
}

@end
