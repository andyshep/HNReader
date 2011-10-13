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
            
            // entries table is the third table on screen
            // if there is a black banner, it is the forth table
            // hackiness ensues...
            HTMLNode *titleNode = [[bodyNode findChildrenOfClass:@"title"] objectAtIndex:0];
            NSString *titleString = [[titleNode firstChild] contents];
            NSString *siteURL = [[titleNode firstChild] getAttributeNamed:@"href"];
            NSArray *tableNodes = [bodyNode findChildTags:@"tr"];
            NSString *bgColor = [[tableNodes objectAtIndex:0] getAttributeNamed:@"bgcolor"];
            
            HTMLNode *commentsTableRow = [tableNodes objectAtIndex:3];
            if ([bgColor compare:@"#000000"] == NSOrderedSame)
                commentsTableRow = [tableNodes objectAtIndex:4];
            
            NSMutableArray *_comments = nil;
            NSArray *commentsTableArray = [[commentsTableRow firstChild] findChildTags:@"table"];
            
            // make sure we have comments
            if ([commentsTableArray count]  > 1) {
                HTMLNode *commentsTable = [[[commentsTableRow firstChild] findChildTags:@"table"] objectAtIndex:1];
                NSArray *commentsNodes = [commentsTable children];
                int commentCount = [[commentsTable children] count];
                
                _comments = [NSMutableArray arrayWithCapacity:commentCount];
                
                for (HTMLNode *comment in commentsNodes) {
                    
                    HTMLNode *comHead = [comment findChildOfClass:@"comhead"];
                    NSString *commentUserName = nil;
                    NSString *commentString = nil;
                    NSString *timeSinceCreation = nil;
                    int commentPadding = 0;
                    
                    // make sure comment wasn't deleted.
                    if ([[comHead children] count] > 0) {
                        commentUserName = [[[comment findChildOfClass:@"comhead"] firstChild] contents];
                        HTMLNode *commentTextSpan = [comment findChildOfClass:@"comment"];
                        commentPadding = [[[comment findChildTag:@"img"] getAttributeNamed:@"width"] integerValue];
                        
                        NSString *rawCommentHTML = [[commentTextSpan findChildTag:@"font"] rawContents];
                        commentString = [self formatCommentText:rawCommentHTML];
                        
                        NSString *roughTime = [[[comHead children] objectAtIndex:1] rawContents];
                        timeSinceCreation = [roughTime substringToIndex:[roughTime length] - 2];
                    }
                    else {
                        commentUserName = @"";
                        commentString = @"[deleted]";
                        commentPadding = [[[comment findChildTag:@"img"] getAttributeNamed:@"width"] integerValue];
                    }
                    
                    HNComment *aComment = [[HNComment alloc] init];
                    aComment.username = commentUserName;
                    aComment.padding = commentPadding;
                    aComment.commentString = commentString;
                    aComment.timeSinceCreation = timeSinceCreation;
                    
                    [_comments addObject:aComment];
                    [aComment release];
                }
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

- (void)cancelRequest {
    [opQueue cancelAllOperations];
}

- (NSString *)formatCommentText:(NSString *)commentText {
    
    commentText = [commentText stringByRemovingHTMLTags];
    commentText = [commentText stringByDecodingHTMLEntities];
    commentText = [commentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return commentText;
}

@end
