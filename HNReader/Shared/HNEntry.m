//
//  HNEntry.m
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNEntry.h"

@implementation HNEntry

- (id)init {
    if ((self = [super init])) {
        //
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.linkURL = [aDecoder decodeObjectForKey:@"linkURL"];
        self.siteDomainURL = [aDecoder decodeObjectForKey:@"siteDomainURL"];
        self.commentsPageURL = [aDecoder decodeObjectForKey:@"commentsPageURL"];
        self.commentsCount = [aDecoder decodeObjectForKey:@"commentsCount"];
        self.totalPoints = [aDecoder decodeObjectForKey:@"totalPoints"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.linkURL forKey:@"linkURL"];
    [aCoder encodeObject:self.siteDomainURL forKey:@"siteDomainURL"];
    [aCoder encodeObject:self.commentsPageURL forKey:@"commentsPageURL"];
    [aCoder encodeObject:self.commentsCount forKey:@"commentsCount"];
    [aCoder encodeObject:self.totalPoints forKey:@"totalPoints"];
    [aCoder encodeObject:self.username forKey:@"username"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ :: %@", _title, _commentsPageURL];
}

@end
