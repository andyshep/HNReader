//
//  HNComment.m
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNComment.h"

@implementation HNComment

@synthesize username, commentString, padding, height;

- (id)init {
    if ((self = [super init])) {
        self.username = nil;
        self.commentString = nil;
        self.padding = 0;
        self.height = 0.0f;
    }
    
    return self;
}

- (void)dealloc {
    [username release];
    [commentString release];
    [super dealloc];
}

@end
