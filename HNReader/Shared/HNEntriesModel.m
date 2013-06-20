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
        
        // https://github.com/gowalla/AFNetworking/issues/47
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
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

#pragma mark - Cache Management

- (NSString *)cacheFilePathForIndex:(NSUInteger)index {
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cacheFilePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"front.plist"]];
    
    if (index == HNEntriesNewestPageIdentifier) {
        cacheFilePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"newest.plist"]];
    }
    else if (index == HNEntriesBestPageIdentifier) {
        cacheFilePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"best.plist"]];
    }
    
    return cacheFilePath;
}

- (NSURL *)pageURLForIndex:(NSUInteger)index {
    NSURL *url = [NSURL URLWithString:@"http://news.ycombinator.com/"];
    
    if (index == HNEntriesNewestPageIdentifier) {
        url = [NSURL URLWithString:@"http://news.ycombinator.com/newest"];
    }
    else if (index == HNEntriesBestPageIdentifier) {
        url = [NSURL URLWithString:@"http://news.ycombinator.com/best"];
    }
    
    return url;
}

- (int)cacheTimeForPageIndex:(NSUInteger)index {
    int time = 180;
    
    if (index == HNEntriesNewestPageIdentifier) {
        time = 60;
    }
    else if (index == HNEntriesBestPageIdentifier) {
        time = 7200;
    }
    
    return time;
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
    
    // determine if the cache is valid
    NSString *filePath = [self cacheFilePathForIndex:index];
    NSError *err;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:&err];
    if (attrs != nil && [attrs count] > 0) {
        
        // alway load from cache first
        NSArray *cachedEntries = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        [self willChangeValueForKey:@"entries"];
        [self.entries removeAllObjects];
        [self.entries addObjectsFromArray:cachedEntries];
        [self didChangeValueForKey:@"entries"];
        
        
        NSDate *date = [attrs valueForKey:@"NSFileModificationDate"];
        if (date != nil) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
            if (interval > [self cacheTimeForPageIndex:index]) {
                NSURL *url = [self pageURLForIndex:index];
                NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
                [self loadEntriesForRequest:request atCachedFilePath:filePath];
            }
        }
    }
    else {
        [self reloadEntriesForIndex:index];
    }
}

- (void)reloadEntriesForIndex:(NSUInteger)index {
    NSString *filePath = [self cacheFilePathForIndex:index];
    NSURL *url = [self pageURLForIndex:index];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [self loadEntriesForRequest:request atCachedFilePath:filePath];
}

- (void)loadMoreEntriesForIndex:(NSUInteger)index {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://news.ycombinator.com%@", moreEntriesLink]];
    
//    if (![moreEntriesLink hasPrefix:@"/"]) {
//        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://news.ycombinator.com/%@", moreEntriesLink]];
//    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    
    // we can keep the old entries around if we're loading more
    // TODO: need to pass in an idnex or something here
    NSString *cachedFilePath = [self cacheFilePathForIndex:index];
    [self loadEntriesForRequest:request atCachedFilePath:cachedFilePath];
}

-(void)loadEntriesForRequest:(NSURLRequest *)request atCachedFilePath:(NSString *)cachedFilePath {
    // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://news.ycombinator.com/newest"]];
    // NSURLRequest *_request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/best.html"]];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *aParserError = nil;
        NSString *rawHTML = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        HTMLParser *parser = [[HTMLParser alloc] initWithString:rawHTML error:&aParserError];
        [rawHTML release];
        
        if (aParserError) {
            self.error = aParserError;
            [parser release];
            return;
        }
        
        HTMLNode *bodyNode = [parser body];
        
        // entries table is the third table on screen
        HTMLNode *entiresTable = [[bodyNode findChildTags:@"table"] objectAtIndex:2];
        NSArray *tableNodes = [entiresTable findChildTags:@"tr"];
        
        // NSMutableArray *_entries = [NSMutableArray arrayWithCapacity:20];
        HTMLNode *_currentNode = [tableNodes objectAtIndex:0];
        
        NSMutableArray *parsedEntries = [NSMutableArray arrayWithCapacity:30];
        
        while ([_currentNode allContents] != NULL) {
            
            // the title <td> has a CSS class of title
            // we are concerned with the second one
            NSArray *titles = [_currentNode findChildrenOfClass:@"title"];
            
            if ([titles count] > 1) {
                
                HNEntry *aEntry = [[HNEntry alloc] init];
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
                [parsedEntries addObject:aEntry];
                [aEntry release];
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
            
            if (![_moreEntriesLink hasPrefix:@"/"]) {
                _moreEntriesLink = [NSString stringWithFormat:@"/%@", _moreEntriesLink];
            }
            
            self.moreEntriesLink = _moreEntriesLink;
            
            // [_entries addObject:[NSString stringWithString:[[moreEntriesNode firstChild] getAttributeNamed:@"href"]]];
        }
        else {
            self.error = [self parserError];
            [parser release];
            return;
        }
        
        [parser release];
        
        // now we set the entires
        [self willChangeValueForKey:@"entries"];
        [self.entries removeAllObjects];
        [self.entries addObjectsFromArray:parsedEntries];
        [self didChangeValueForKey:@"entries"];
        
        // save the entries the disk for next time
        [NSKeyedArchiver archiveRootObject:entries toFile:cachedFilePath];
    } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
        // log network connection error;
        self.error = err;
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
