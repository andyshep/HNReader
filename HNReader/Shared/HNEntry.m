//
//  HNEntry.m
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntry.h"

@implementation HNEntry

@synthesize title, linkURL, siteDomainURL;
@synthesize username;
@synthesize commentsPageURL, commentsCount;
@synthesize totalPoints;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        title = nil, linkURL = nil;
        siteDomainURL = nil;
        username = nil;
        commentsPageURL = nil, commentsCount = nil;
        totalPoints = nil;
    }
    
    return self;
}

- (void)dealloc {
    [title release];
    [linkURL release];
    [siteDomainURL release];
    
    [commentsCount release];
    [commentsPageURL release];
    [totalPoints release];
    
    [username release];
    [super dealloc];
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
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:linkURL forKey:@"linkURL"];
    [aCoder encodeObject:siteDomainURL forKey:@"siteDomainURL"];
    [aCoder encodeObject:commentsPageURL forKey:@"commentsPageURL"];
    [aCoder encodeObject:commentsCount forKey:@"commentsCount"];
    [aCoder encodeObject:totalPoints forKey:@"totalPoints"];
    [aCoder encodeObject:username forKey:@"username"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ :: %@", title, commentsPageURL];
    //return [NSString stringWithFormat:@"%@", title];
}

@end
