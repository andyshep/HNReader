//
//  HNCommentsModel.m
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNCommentsModel.h"

@implementation HNCommentsModel

@synthesize commentsInfo, error, entry;

- (id)initWithEntry:(HNEntry *)aEntry {
    if ((self = [super init])) {
        self.commentsInfo = nil;
        self.error = nil;
        self.entry = aEntry;
        
        opQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [commentsInfo release];
    [error release];
    [entry release];
    [opQueue release];
    [super dealloc];
}

#pragma mark - KVC
// our view controller uses these to display table data

- (NSUInteger)countOfComments {
	return [[commentsInfo objectForKey:@"comments"] count];
}

- (id)objectInCommentsAtIndex:(NSUInteger)index {
	return [[commentsInfo objectForKey:@"comments"] objectAtIndex:index];
}

- (void)getCommentsObjects:(id *)objects range:(NSRange)range {
	[[commentsInfo objectForKey:@"comments"] getObjects:objects range:range];
}

- (void)loadComments {
    
    
    NSURL *_url = [NSURL URLWithString:[NSString stringWithFormat:@"http://news.ycombinator.com/%@", self.entry.commentsPageURL]];
    NSURLRequest *_request = [NSURLRequest requestWithURL:_url];
    
    [self loadCommentsForRequest:_request];
}

-(void)loadCommentsForRequest:(NSURLRequest *)request {
    // NSURLRequest *_request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://news.ycombinator.com/rss"]];
    // NSURLRequest *_request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/comments.html"]];
    
    AFHTTPRequestOperation *operation = [AFHTTPRequestOperation operationWithRequest:request completion:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *err) {
        // NSLog(@"data: %@", data);
        
        if (!err) {
            NSError *parserError = nil;
            NSString *rawHTML = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            HTMLParser *parser = [[HTMLParser alloc] initWithString:rawHTML error:&parserError];
            
            if (parserError != nil) {
                NSLog(@"Error: %@", [parserError localizedDescription]);
                // return;
            }
            
            HTMLNode *bodyNode = [parser body];

            // NSLog(@"bodyNode: %@", [bodyNode rawContents]);
            
            // entries table is the third table on screen
            HTMLNode *titleNode = [[bodyNode findChildrenOfClass:@"title"] objectAtIndex:0];
            NSString *titleString = [[titleNode firstChild] contents];
            NSString *siteURL = [[titleNode firstChild] getAttributeNamed:@"href"];
            
            NSArray *tableNodes = [bodyNode findChildTags:@"tr"];
            
            HTMLNode *commentsTableRow = [tableNodes objectAtIndex:3];
            HTMLNode *commentsTable = [[[commentsTableRow firstChild] findChildTags:@"table"] objectAtIndex:1];
            NSArray *commentsNodes = [commentsTable children];
            int commentCount = [[commentsTable children] count];
            
            NSMutableArray *_comments = [NSMutableArray arrayWithCapacity:commentCount];
            
            for (HTMLNode *comment in commentsNodes) {
                
                // NSString *commentUserName = [[[comment findChildOfClass:@"comhead"] firstChild] contents];
                HTMLNode *commentTextSpan = [comment findChildOfClass:@"comment"];
                int commentPaddding = [[[comment findChildTag:@"img"] getAttributeNamed:@"width"] integerValue];
                
                
                // NSLog(@"%@", [[commentTextSpan findChildTag:@"font"] contents]);
                NSString *rawCommentHTML = [[commentTextSpan findChildTag:@"font"] rawContents];
                NSString *commentString = [self formatCommentText:rawCommentHTML];
                
                HNComment *aComment = [[HNComment alloc] init];
                aComment.username = @"Bob";
                aComment.padding = commentPaddding;
                aComment.commentString = commentString;

                [_comments addObject:aComment];
                [aComment release];
            }
            
            NSMutableDictionary *_commentsInfo = [NSMutableDictionary dictionaryWithCapacity:3];
            [_commentsInfo setValue:titleString forKey:@"entry_title"];
            [_commentsInfo setValue:siteURL forKey:@"entry_url"];
            [_commentsInfo setValue:[NSArray arrayWithArray:_comments] forKey:@"entry_comments"];
            
            self.commentsInfo = _commentsInfo;
            
            [parser release];
        }
        else {
            // log network connection error;
            self.error = err;
        }
    }];
    
    [opQueue addOperation:operation];
}

- (NSString *)formatCommentText:(NSString *)commentText {
    
    commentText = [commentText stringByRemovingHTMLTags];
    commentText = [commentText stringByDecodingHTMLEntities];
    commentText = [commentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return commentText;
}

@end
