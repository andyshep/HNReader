//
//  HNCommentsModel.h
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "HNEntry.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

#import "HNComment.h"

// #import "NSAttributedString+HTML.h"

@interface HNCommentsModel : NSObject {
    NSMutableDictionary *commentsInfo;
    NSError *error;
    
    NSOperationQueue *opQueue;
}

@property (copy) NSMutableDictionary *commentsInfo;
@property (copy) NSError *error;

-(void)loadCommentsForRequest:(NSURLRequest *)request;

@end
