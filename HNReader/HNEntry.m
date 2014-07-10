//
//  HNEntry.m
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNEntry.h"

@implementation HNEntry

- (instancetype)init {
    if (self = [super init]) {
        //
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.linkURL = [aDecoder decodeObjectForKey:@"linkURL"];
        self.commentsPageURL = [aDecoder decodeObjectForKey:@"commentsPageURL"];
        self.siteDomainURL = [aDecoder decodeObjectForKey:@"siteDomainURL"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.commentsCount = [aDecoder decodeObjectForKey:@"commentsCount"];
        self.totalPoints = [aDecoder decodeObjectForKey:@"totalPoints"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.linkURL forKey:@"linkURL"];
    [aCoder encodeObject:self.commentsPageURL forKey:@"commentsPageURL"];
    [aCoder encodeObject:self.siteDomainURL forKey:@"siteDomainURL"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.commentsCount forKey:@"commentsCount"];
    [aCoder encodeObject:self.totalPoints forKey:@"totalPoints"];
}

- (NSUInteger)hash {
    return self.commentsPageURL.hash;
}

- (BOOL)isEqual:(HNEntry *)entry {
    if (![entry isKindOfClass:[HNEntry class]]) {
        return NO;
    }
    
    BOOL equal = [self.commentsPageURL isEqualToString:entry.commentsPageURL] && [self.username isEqualToString:entry.username];
    return equal;
}

@end
