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

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        title = nil, linkURL = nil;
        siteDomainURL = nil;
        username = nil;
        commentsPageURL = nil, commentsCount = nil;
    }
    
    return self;
}

- (void)dealloc {
    [title release];
    [linkURL release];
    [siteDomainURL release];
    
    [commentsCount release];
    [commentsPageURL release];
    
    [username release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ :: %@", title, linkURL];
    //return [NSString stringWithFormat:@"%@", title];
}

@end
