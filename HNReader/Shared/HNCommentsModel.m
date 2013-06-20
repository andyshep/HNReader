//
//  HNCommentsModel.m
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNCommentsModel.h"

#import "AFHTTPRequestOperation.h"
#import "HNEntry.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

#import "HNComment.h"
#import "HNEntry.h"

#import "NSString+HTML.h"

@interface HNCommentsModel ()

@property (nonatomic, strong) NSOperationQueue *queue;

- (NSString *)cacheFilePath;
- (NSString *)formatedCommentText:(NSString *)commentText;

@end

@implementation HNCommentsModel

- (id)initWithEntry:(HNEntry *)entry {
    if ((self = [super init])) {
        self.entry = entry;
        self.queue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

#pragma mark - KVC
- (NSUInteger)countOfComments {
	return [_commentsInfo[@"comments"] count];
}

- (id)objectInCommentsAtIndex:(NSUInteger)index {
	return _commentsInfo[@"comments"][index];
}

- (void)getCommentsObjects:(__unsafe_unretained id *)objects range:(NSRange)range {
	[[_commentsInfo objectForKey:@"comments"] getObjects:objects range:range];
}

#pragma mark - Cache Management
- (NSString *)cacheFilePath {
    NSString *commentId = [[_entry commentsPageURL] substringFromIndex:8];
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cacheFilePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"comments_%@.plist", commentId]];
    
    return cacheFilePath;
}

- (void)loadComments {
    // determine if the cache is valid
    NSString *filePath = [self cacheFilePath];
    NSError *err;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:&err];
    if (attrs != nil && [attrs count] > 0) {
        
        // alway load from cache first
        NSDictionary *cachedComments = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        
        //[self willChangeValueForKey:@"commentsInfo"];
        self.commentsInfo = [NSMutableDictionary dictionaryWithDictionary:cachedComments];
        // [self didChangeValueForKey:@"commentsInfo"];
        
        NSDate *date = [attrs valueForKey:@"NSFileModificationDate"];
        if (date != nil) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
            if (interval > 120) {
                NSURL *_url = [NSURL URLWithString:[NSString stringWithFormat:@"http://news.ycombinator.com/%@", [_entry commentsPageURL]]];
                NSURLRequest *_request = [NSURLRequest requestWithURL:_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
                [self loadCommentsForRequest:_request];
            }
        }
    }
    else {
        NSURL *_url = [NSURL URLWithString:[NSString stringWithFormat:@"http://news.ycombinator.com/%@", [_entry commentsPageURL]]];
        NSURLRequest *_request = [NSURLRequest requestWithURL:_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        [self loadCommentsForRequest:_request];
    }
}

-(void)loadCommentsForRequest:(NSURLRequest *)request {
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parserError = nil;
        NSString *rawHTML = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        HTMLParser *parser = [[HTMLParser alloc] initWithString:rawHTML error:&parserError];
        
        if (parserError != nil) {
            NSLog(@"Error: %@", [parserError localizedDescription]);
            // return;
        }
        
        HTMLNode *bodyNode = [parser body];
        
        // entries table is the third table on screen
        // if there is a black banner, it is the forth table
        // hackiness ensues...
        
        // ignore anything without a title, like job postings from yc alum
        if ([[bodyNode findChildrenOfClass:@"title"] count] <= 0) {
            return;
        }
        
        HTMLNode *titleNode = [bodyNode findChildrenOfClass:@"title"][0];
        NSString *titleString = [[titleNode firstChild] contents];
        NSString *siteURL = [[titleNode firstChild] getAttributeNamed:@"href"];
        NSArray *tableNodes = [bodyNode findChildTags:@"tr"];
        NSString *bgColor = [[tableNodes[0] firstChild] getAttributeNamed:@"bgcolor"];
        
        HTMLNode *commentsTableRow = tableNodes[3];
        if (bgColor != nil && [bgColor compare:@"#000000"] == NSOrderedSame) {
            commentsTableRow = tableNodes[4];
        }
        
        NSMutableArray *_comments = nil;
        NSArray *commentsTableArray = [[commentsTableRow firstChild] findChildTags:@"table"];
        
        // make sure we have comments
        if ([commentsTableArray count]  > 1) {
            HTMLNode *commentsTable = [[commentsTableRow firstChild] findChildTags:@"table"][1];
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
                    commentString = [self formatedCommentText:rawCommentHTML];
                    
                    NSString *roughTime = [[comHead children][1] rawContents];
                    timeSinceCreation = [roughTime substringToIndex:[roughTime length] - 2];
                } else {
                    commentUserName = @"";
                    commentString = @"[deleted]";
                    commentPadding = [[[comment findChildTag:@"img"] getAttributeNamed:@"width"] integerValue];
                }
                
                HNComment *comment = [[HNComment alloc] init];
                comment.username = commentUserName;
                comment.padding = commentPadding;
                comment.commentString = commentString;
                comment.timeSinceCreation = timeSinceCreation;
                
                [_comments addObject:comment];
            }
        }
        
        NSMutableDictionary *commentsInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        [commentsInfo setValue:titleString forKey:@"entry_title"];
        [commentsInfo setValue:siteURL forKey:@"entry_url"];
        [commentsInfo setValue:[NSArray arrayWithArray:_comments] forKey:@"entry_comments"];
        
        self.commentsInfo = commentsInfo;
        
        // save the entries the disk for next time
        [NSKeyedArchiver archiveRootObject:commentsInfo toFile:[self cacheFilePath]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
        // log network connection error;
        self.error = err;
    }];
    
    [_queue addOperation:operation];
}

- (void)cancelRequest {
    [_queue cancelAllOperations];
}

- (NSString *)formatedCommentText:(NSString *)commentText {
    commentText = [commentText stringByConvertingHTMLToPlainText];
    commentText = [commentText stringByDecodingHTMLEntities];
    commentText = [commentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return commentText;
}

@end
