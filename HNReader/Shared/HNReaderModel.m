//
//  HNReaderModel.m
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderModel.h"

@implementation HNReaderModel

@synthesize entries, error, moreEntriesLink;

- (id)init
{
    self = [super init];
    if (self) {
        self.entries = nil;
        self.error = nil;
        self.moreEntriesLink = nil;
        
        opQueue = [[NSOperationQueue alloc] init];
        entries = [[NSMutableArray alloc] initWithCapacity:25];
    }
    
    return self;
}

- (void)dealloc {
    [entries release];
    [error release];
    [moreEntriesLink release];
    
    [opQueue release];
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

- (void)loadEntriesForIndex:(NSUInteger)index {
    
    // remove all entries
    // presumably we've switched pages via teh control
    if ([entries count] > 0) {
        [self willChangeValueForKey:@"entries"];
        [entries removeAllObjects];
        [self didChangeValueForKey:@"entries"];
    }
    
    NSURL *url = [NSURL URLWithString:@"http://news.ycombinator.com/"];
    
    if (index == HNEntriesNewestPageIdentifier) {
        url = [NSURL URLWithString:@"http://news.ycombinator.com/newest"];
    }
    else if (index == HNEntriesBestPageIdentifier) {
        url = [NSURL URLWithString:@"http://news.ycombinator.com/best"];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self loadEntriesForRequest:request];
}

- (void)loadMoreEntries {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://news.ycombinator.com%@", moreEntriesLink]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // we can keep the old entries around if we're loading more
    [self loadEntriesForRequest:request];
}

-(void)loadEntriesForRequest:(NSURLRequest *)request {
    // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://news.ycombinator.com/newest"]];
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
            
            // NSMutableArray *_entries = [NSMutableArray arrayWithCapacity:20];
            HTMLNode *_currentNode = [tableNodes objectAtIndex:0];
            
            [self willChangeValueForKey:@"entries"];
            
            while ([_currentNode allContents] != NULL) {
                
                // the title <td> has a CSS class of title
                // we are concerned with the second one
                NSArray *titles = [_currentNode findChildrenOfClass:@"title"];
                
                if ([titles count] > 1) {
                    
                    // NSLog(@"%@", [_currentNode rawContents]);
                    
                    HNEntry *aEntry = [[[HNEntry alloc] init] autorelease];
                    aEntry.title = [[[titles objectAtIndex:1] firstChild] contents];
                    aEntry.linkURL = [[[titles objectAtIndex:1] firstChild] getAttributeNamed:@"href"];
                    aEntry.siteDomainURL = [[[titles objectAtIndex:1] findChildOfClass:@"comhead"] contents];
                    
                    // NSLog(@"%@", aEntry.linkURL);
                    
                    if ([aEntry.linkURL hasPrefix:@"item?id="]) {
                        
                        NSString *baseURL = @"http://news.ycombinator.com/";
                        
                        aEntry.linkURL = [baseURL stringByAppendingString:aEntry.linkURL];
                    }
                    
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
                    
                    // [_entries addObject:aEntry];
                    [self.entries addObject:aEntry];
                }
                
                // move to the next node
                // which may or may not be a title.
                _currentNode = [_currentNode nextSibling];
            }
            
            // after we have all the entries
            // we grab the link the load the next 25 or so entries
            // we will load these next 25 when the user selects the last table cell
            
            HTMLNode *moreEntriesNode = [[tableNodes lastObject] findChildOfClass:@"title"];
            
            if (moreEntriesNode != NULL) {
                NSLog(@"%@", [[moreEntriesNode firstChild] getAttributeNamed:@"href"]);
                
                NSString *_moreEntriesLink = [[moreEntriesNode firstChild] getAttributeNamed:@"href"];
                self.moreEntriesLink = _moreEntriesLink;
                
                // [_entries addObject:[NSString stringWithString:[[moreEntriesNode firstChild] getAttributeNamed:@"href"]]];
            }
            
            // self.entries = _entries;
            
            [self didChangeValueForKey:@"entries"];
            
            [parser release];
        }
    }];
    
    [opQueue addOperation:operation];
}

#pragma mark - Response Parsing

- (void)handleResponse {
    
}

@end
