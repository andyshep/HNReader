//
//  HNEntriesModel.m
//  HNEntriesModel
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntriesModel.h"

@implementation HNEntriesModel

@synthesize entries, error, moreEntriesLink;

- (id)init
{
    self = [super init];
    if (self) {
        self.entries = nil;
        self.error = nil;
        self.moreEntriesLink = nil;
        
        opQueue = [[NSOperationQueue alloc] init];
        entries = [[NSMutableArray alloc] initWithCapacity:30];
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
    // NSURLRequest *_request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/best.html"]];
    
    AFHTTPRequestOperation *operation = [AFHTTPRequestOperation operationWithRequest:request completion:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *err) {
        // NSLog(@"data: %@", data);
        
        if (!err) {
            NSError *aParserError = nil;
            NSString *rawHTML = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            HTMLParser *parser = [[HTMLParser alloc] initWithString:rawHTML error:&aParserError];
            
            if (aParserError) {
                self.error = aParserError;
                return;
            }
            
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
                    
                    HNEntry *aEntry = [[[HNEntry alloc] init] autorelease];
                    aEntry.title = [[[titles objectAtIndex:1] firstChild] contents];
                    aEntry.linkURL = [[[titles objectAtIndex:1] firstChild] getAttributeNamed:@"href"];
                    aEntry.siteDomainURL = [[[titles objectAtIndex:1] findChildOfClass:@"comhead"] contents];
                    
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
                    // YC alumi job posts
                    if ([[commentTdNode children] count] == 5) {
                        
                        aEntry.totalPoints = [[[commentTdNode children] objectAtIndex:0] contents];
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
            // we grab the link the load the next 30 entries
            // we will load these next 30 when the user selects the last table cell
            
            HTMLNode *moreEntriesNode = [[tableNodes lastObject] findChildOfClass:@"title"];
            
            if (moreEntriesNode != NULL) {
                NSString *_moreEntriesLink = [[moreEntriesNode firstChild] getAttributeNamed:@"href"];
                self.moreEntriesLink = _moreEntriesLink;
                
                // [_entries addObject:[NSString stringWithString:[[moreEntriesNode firstChild] getAttributeNamed:@"href"]]];
            }
            else {
                self.error = [self parserError];
                return;
            }
            
            [self didChangeValueForKey:@"entries"];
            [parser release];
        }
        else {
            // log network connection error;
            self.error = err;
        }
    }];
    
    [opQueue addOperation:operation];
}

#pragma mark - Response Parsing

- (void)handleResponse {
    
}

- (NSError *)parserError {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:@"Error parsing HTML response" forKey:NSLocalizedDescriptionKey];
    NSError *parserError = [NSError errorWithDomain:@"org.andyshep.HNReader" code:100 userInfo:errorDetail];
    
    return parserError;
}

@end
