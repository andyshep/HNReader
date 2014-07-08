//
//  HNConstants.m
//  HNReader
//
//  Created by Andrew Shepard on 7/3/14.
//
//

#import "HNConstants.h"

NSString * const HNCommentsViewControllerIdentifier = @"HNCommentsViewController";
NSString * const HNWebViewControllerIdentifier = @"HNWebViewController";

NSString * const HNEntriesTableViewCellIdentifier = @"HNEntriesTableViewCell";
NSString * const HNCommentsTableViewCellIdentifier = @"HNCommentsTableViewCell";
NSString * const HNLoadMoreTableViewCellIdentifier = @"HNLoadMoreTableViewCell";

NSString * const HNWebsiteURLKey = @"HNWebSiteURL";

NSString * const HNFrontPageKey = @"front";
NSString * const HNBestPageKey = @"best";
NSString * const HNNewestPageKey = @"newest";

NSString * const HNWebsiteBaseURL = @"http://news.ycombinator.com";
NSString * const HNWebsitePlaceholderURL = @"http://news.ycombinator.com/%@";

NSString * const HNEntriesKeyPath = @"entries";
NSString * const HNCommentsKeyPath = @"comments";

NSString * const HNEntriesKey = @"HNEntries";
NSString * const HNEntryCommentsKey = @"HNEntryCommments";
NSString * const HNEntryTitleKey = @"HNEntryTitle";
NSString * const HNEntryURLKey = @"HNEntryURL";
NSString * const HNEntryNextKey = @"HNNextEntry";

CGFloat const HNDefaultTableCellHeight = 72.0f;
CGFloat const HNMaxDatabaseCacheInterval = 360.0f;
