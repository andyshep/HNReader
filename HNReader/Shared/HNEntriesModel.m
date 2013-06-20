//
//  HNEntriesModel.m
//  HNEntriesModel
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNEntriesModel.h"

#import "AFHTTPRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"

#import "HNEntry.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

typedef enum  {
    HNEntriesFrontPageIdentifier,
    HNEntriesNewestPageIdentifier,
    HNEntriesBestPageIdentifier
} HNEntriesPageIdentifier;

@interface HNEntriesModel ()

@property (nonatomic, strong) NSOperationQueue *queue;

- (NSString *)cacheFilePathForIndex:(NSUInteger)index;
- (NSURL *)pageURLForIndex:(NSUInteger)index;
- (int)cacheTimeForPageIndex:(NSUInteger)index;

@end

@implementation HNEntriesModel

- (void)setEntries:(NSMutableArray *)entries {
    _entries = [entries mutableCopy];
}

- (id)init {
    if ((self = [super init])) {
        self.queue = [[NSOperationQueue alloc] init];
        self.entries = [[NSMutableArray alloc] initWithCapacity:30];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    }
    
    return self;
}

#pragma mark - KVC
- (NSUInteger)countOfEntries {
	return self.entries.count;
}

- (id)objectInEntriesAtIndex:(NSUInteger)index {
	return self.entries[index];
}

- (void)getEntriesObjects:(__unsafe_unretained id *)objects range:(NSRange)range {
    [self.entries getObjects:objects range:range];
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
    if ([_entries count] > 0) {
        [self willChangeValueForKey:@"entries"];
        [_entries removeAllObjects];
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
        [_entries removeAllObjects];
        [_entries addObjectsFromArray:cachedEntries];
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://news.ycombinator.com%@", _moreEntriesLink]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    // we can keep the old entries around if we're loading more
    // TODO: need to pass in an idnex or something here
    NSString *cachedFilePath = [self cacheFilePathForIndex:index];
    [self loadEntriesForRequest:request atCachedFilePath:cachedFilePath];
}

- (void)loadEntriesForRequest:(NSURLRequest *)request atCachedFilePath:(NSString *)cachedFilePath {    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *aParserError = nil;
        NSString *rawHTML = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        HTMLParser *parser = [[HTMLParser alloc] initWithString:rawHTML error:&aParserError];
        
        if (aParserError) {
            self.error = aParserError;
            return;
        }
        
        HTMLNode *bodyNode = [parser body];
        
        // entries table is the third table on screen
        HTMLNode *entiresTable = [bodyNode findChildTags:@"table"][2];
        NSArray *tableNodes = [entiresTable findChildTags:@"tr"];
        
        HTMLNode *_currentNode = tableNodes[0];
        NSMutableArray *parsedEntries = [NSMutableArray arrayWithCapacity:30];
        
        while ([_currentNode allContents] != NULL) {
            
            // the title <td> has a CSS class of title
            // we are concerned with the second one
            NSArray *titles = [_currentNode findChildrenOfClass:@"title"];
            
            if ([titles count] > 1) {
                HNEntry *entry = [[HNEntry alloc] init];
                entry.title = [[titles[1] firstChild] contents];
                entry.linkURL = [[titles[1] firstChild] getAttributeNamed:@"href"];
                entry.siteDomainURL = [[titles[1] findChildOfClass:@"comhead"] contents];
                
                if ([entry.linkURL hasPrefix:@"item?id="]) {
                    NSString *baseURL = @"http://news.ycombinator.com/";
                    entry.linkURL = [baseURL stringByAppendingString:entry.linkURL];
                }
                
                // after the title <td>, the next child is a commment <td>
                // we move to the next child and extract comments
                HTMLNode *commentNode = [_currentNode nextSibling];
                HTMLNode *commentTdNode = [commentNode findChildOfClass:@"subtext"];
                
                // some stories don't have comments
                // YC alumi job posts
                if ([[commentTdNode children] count] == 5) {
                    entry.totalPoints = [[commentTdNode children][0] contents];
                    entry.username = [[commentTdNode children][2] contents];
                    entry.commentsPageURL = [[commentTdNode children][4] getAttributeNamed:@"href"];
                    entry.commentsCount = [[commentTdNode children][4] contents];
                }
                
                [parsedEntries addObject:entry];
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
            NSString *moreEntriesLink = [[moreEntriesNode firstChild] getAttributeNamed:@"href"];
            
            if (![moreEntriesLink hasPrefix:@"/"]) {
                moreEntriesLink = [NSString stringWithFormat:@"/%@", _moreEntriesLink];
            }
            
            self.moreEntriesLink = moreEntriesLink;
        }
        else {
            self.error = [self parserError];
            return;
        }
        
        // now we set the entires
        [self willChangeValueForKey:@"entries"];
        [self.entries removeAllObjects];
        [self.entries addObjectsFromArray:parsedEntries];
        [self didChangeValueForKey:@"entries"];
        
        // save the entries the disk for next time
        [NSKeyedArchiver archiveRootObject:_entries toFile:cachedFilePath];
    } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
        // log network connection error;
        self.error = err;
    }];
        
    [_queue addOperation:operation];
}

- (void)handleResponse {
    // TODO:
}

- (NSError *)parserError {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:@"Error parsing HTML response" forKey:NSLocalizedDescriptionKey];
    NSError *parserError = [NSError errorWithDomain:@"org.andyshep.HNReader" code:100 userInfo:errorDetail];
    
    return parserError;
}

@end
