//
//  HNParser.m
//  HNReader
//
//  Created by Andrew Shepard on 1/31/14.
//  Copyright 2014 Andrew Shepard. All rights reserved.
//

#import "HNParser.h"

#import "HTMLParser.h"
#import "HTMLNode.h"

#import "HNEntry.h"
#import "HNComment.h"

#import "NSString+HTML.h"
#import "NSString+HNCommentTools.h"

#import "HNConstants.h"

@implementation HNParser

+ (NSDictionary *)parsedEntriesFromResponse:(id)response {
    NSMutableArray *entries = [NSMutableArray array];
    NSString *next = @"";
    
    NSError *error = nil;
    NSString *html = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    
    if (!error) {
        HTMLNode *bodyNode = [parser body];
        
        // entries table is the third table on screen
        HTMLNode *entiresTable = [bodyNode findChildTags:@"table"][2];
        NSArray *tableNodes = [entiresTable findChildTags:@"tr"];
        
        HTMLNode *_currentNode = tableNodes[0];
        while ([_currentNode allContents] != NULL) {
            
            // the title <td> has a CSS class of title
            // we are concerned with the second one
            NSArray *titles = [_currentNode findChildrenOfClass:@"title"];
            
            if ([titles count] > 1) {
                HNEntry *entry = [[HNEntry alloc] init];
                entry.title = [titles[1] allContents];
                
                if ([titles[1] children].count >= 3) {
                    HTMLNode *hrefNode = [titles[1] children][1];
                    HTMLNode *domainNode = [titles[1] children][2];
                    entry.linkURL = [hrefNode getAttributeNamed:@"href"];
                    entry.siteDomainURL = [domainNode allContents];
                }
                
                if ([entry.linkURL hasPrefix:@"item?id="]) {
                    NSString *baseURL = [HNWebsiteBaseURL stringByAppendingString:@"/"];
                    entry.linkURL = [baseURL stringByAppendingString:entry.linkURL];
                }
                
                // after the title <td>, the next child is a commment <td>
                // we move to the next child and extract comments
                HTMLNode *commentNode = [_currentNode nextSibling];
                HTMLNode *commentTdNode = [commentNode findChildOfClass:@"subtext"];
                
                // some stories don't have comments
                // YC alumi job posts
                if ([[commentTdNode children] count] >= 5) {
                    entry.totalPoints = [[commentTdNode children][0] contents];
                    entry.username = [[commentTdNode children][2] contents];
                    entry.commentsPageURL = [[commentTdNode children][4] getAttributeNamed:@"href"];
                    
                    // FIXME
                    entry.commentsCount = [[commentTdNode children][4] contents];
                }
                
                [entries addObject:entry];
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
                moreEntriesLink = [NSString stringWithFormat:@"/%@", moreEntriesLink];
            }
            
            next = moreEntriesLink;
        }
    }
    
    return @{HNEntriesKey: [NSArray arrayWithArray:entries], HNEntryNextKey: next};
}

+ (NSDictionary *)parsedCommentsFromResponse:(id)response {
    NSMutableDictionary *commentsInfo = [NSMutableDictionary dictionary];
    
    NSError *error = nil;
    NSString *html = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    
    if (!error) {
        HTMLNode *bodyNode = [parser body];
        
        // entries table is the third table on screen
        // if there is a black banner, it is the forth table
        // hackiness ensues...
        
        // ignore anything without a title, like job postings from yc alum
        if ([[bodyNode findChildrenOfClass:@"title"] count] > 0) {
            HTMLNode *titleNode = [bodyNode findChildrenOfClass:@"title"][0];
            NSString *titleString = [[titleNode firstChild] contents];
            NSString *siteURL = [[titleNode firstChild] getAttributeNamed:@"href"];
            NSArray *tableNodes = [bodyNode findChildTags:@"tr"];
            NSString *bgColor = [[tableNodes[0] firstChild] getAttributeNamed:@"bgcolor"];
            
            HTMLNode *commentsTableRow = tableNodes[3];
            if (bgColor != nil && [bgColor compare:@"#000000"] == NSOrderedSame) {
                commentsTableRow = tableNodes[4];
            }
            
            NSMutableArray *comments = [NSMutableArray array];
            NSArray *commentsTableArray = [[commentsTableRow firstChild] findChildTags:@"table"];
            
            // make sure we have comments
            if ([commentsTableArray count]  > 1) {
                HTMLNode *commentsTable = [[commentsTableRow firstChild] findChildTags:@"table"][1];
                NSArray *commentsNodes = [commentsTable children];
                
                [commentsNodes enumerateObjectsUsingBlock:^(HTMLNode *node, NSUInteger idx, BOOL *stop) {
                    HTMLNode *comHead = [node findChildOfClass:@"comhead"];
                    NSString *commentUserName = nil;
                    NSString *commentString = nil;
                    NSString *timeSinceCreation = nil;
                    NSUInteger commentPadding = 0;
                    
                    // make sure comment wasn't deleted.
                    if ([[comHead children] count] > 1) {
                        commentUserName = [[[node findChildOfClass:@"comhead"] firstChild] allContents];
                        HTMLNode *commentTextSpan = [node findChildOfClass:@"comment"];
                        commentPadding = [[[node findChildTag:@"img"] getAttributeNamed:@"width"] integerValue];
                        
                        NSString *rawCommentHTML = [[commentTextSpan findChildTag:@"font"] allContents];
                        commentString = [rawCommentHTML hn_stringAsFormatedCommentText];
                        
                        // FIXME
//                        NSString *roughTime = [[comHead children][1] rawContents];
//                        timeSinceCreation = [roughTime substringToIndex:[roughTime length] - 2];
                    } else {
                        commentUserName = @"";
                        commentString = @"[deleted]";
                        commentPadding = [[[node findChildTag:@"img"] getAttributeNamed:@"width"] integerValue];
                    }
                    
                    HNComment *comment = [[HNComment alloc] init];
                    comment.username = commentUserName;
                    comment.padding = commentPadding;
                    comment.commentString = commentString;
                    comment.timeSinceCreation = timeSinceCreation;
                    
                    [comments addObject:comment];
                }];
            }
            
            [commentsInfo setValue:titleString forKey:HNEntryTitleKey];
            [commentsInfo setValue:siteURL forKey:HNEntryURLKey];
            [commentsInfo setValue:[NSArray arrayWithArray:comments] forKey:HNEntryCommentsKey];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:commentsInfo];
}

@end
