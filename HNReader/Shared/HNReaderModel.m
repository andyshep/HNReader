//
//  HNReaderModel.m
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderModel.h"

@implementation HNReaderModel

@synthesize entries, error;

- (id)init
{
    self = [super init];
    if (self) {
        self.entries = nil;
        self.error = nil;
    }
    
    return self;
}

- (void)dealloc {
    [entries release];
    [error release];
    [super dealloc];
}

#pragma mark - KVC
// our view controller uses these to display table data

- (NSUInteger)countOfEntries {
	return [entries count];
}

- (id)objectInEntriesAtIndex:(NSUInteger)index {
	return [entries objectAtIndex:index];
}

- (void)getEntriesObjects:(id *)objects range:(NSRange)range {
	[entries getObjects:objects range:range];
}

#pragma mark - Network Requests

-(void)requestEntries {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://news.ycombinator.com/newest"]];
    // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/best.html"]];
    
    AFHTTPRequestOperation *operation = [AFHTTPRequestOperation operationWithRequest:request completion:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *err) {
        // NSLog(@"data: %@", data);
        
        if (!err) {
            NSError *parserError;
            NSString *rawHTML = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            HTMLParser *parser = [[HTMLParser alloc] initWithString:rawHTML error:&parserError];
            
//            if (parserError) {
//                NSLog(@"Error: %@", [parserError localizedDescription]);
//                // return;
//            }
            
            HTMLNode *bodyNode = [parser body];
            
            // entries table is the third table on screen
            HTMLNode *entiresTable = [[bodyNode findChildTags:@"table"] objectAtIndex:2];
            NSArray *tableNodes = [entiresTable findChildTags:@"tr"];
            
            NSMutableArray *_entries = [NSMutableArray arrayWithCapacity:20];
            HTMLNode *_currentNode = [tableNodes objectAtIndex:0];
            
            while ([_currentNode allContents] != NULL) {
                
                // the title <td> has a CSS class of title
                // we are concerned with the second one
                NSArray *titles = [_currentNode findChildrenOfClass:@"title"];
                
                if ([titles count] > 1) {
                    
                    // NSLog(@"%@", [[[titles objectAtIndex:1] firstChild] contents]);
                    
                    HNEntry *aEntry = [[[HNEntry alloc] init] autorelease];
                    aEntry.title = [[[titles objectAtIndex:1] firstChild] contents];
                    aEntry.linkURL = [[[titles objectAtIndex:1] firstChild] getAttributeNamed:@"href"];
                    aEntry.siteDomainURL = [[[titles objectAtIndex:1] findChildOfClass:@"comhead"] contents];
                    
                    // NSLog(@"%@", [[[titles objectAtIndex:1] findChildOfClass:@"comhead"] contents]);
                    
                    // after the title <td>, the next child is a commment <td>
                    // we move to the next child and extract comments
                    HTMLNode *commentNode = [_currentNode nextSibling];
                    HTMLNode *commentTdNode = [commentNode findChildOfClass:@"subtext"];
                    
                    // some stories don't have comments
                    // YC alumi job posts, for example
                    if ([[commentTdNode children] count] == 5) {
                        aEntry.username = [[[commentTdNode children] objectAtIndex:2] contents];
                        aEntry.commentsPageURL = [[[commentTdNode children] objectAtIndex:4] getAttributeNamed:@"href"];
                        aEntry.commentsCount = [[[commentTdNode children] objectAtIndex:4] contents];
                    }
                    
                    [_entries addObject:aEntry];
                }
                
                // move to the next node
                // which may or may not be a title.
                _currentNode = [_currentNode nextSibling];
            }
            
            self.entries = _entries;
            
            [parser release];
        }
    }];
    
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [queue addOperation:operation];
}

@end
