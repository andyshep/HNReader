//
//  HNConstants.m
//  HNReader
//
//  Created by Andrew Shepard on 7/3/14.
//
//

#import "HNConstants.h"

NSString * const HNCommentsViewControllerIdentifier = @"HNCommentsViewController";

NSString * const HNStopLoadingNotification = @"HNStopLoadingNotification";

NSString * const HNEntriesTableViewCellIdentifier = @"HNEntriesTableViewCell";
NSString * const HNCommentsTableViewCellIdentifier = @"HNCommentsTableViewCell";
NSString * const HNLoadMoreTableViewCellIdentifier = @"HNLoadMoreTableViewCell";

NSString * const HNEntryCommentsKey = @"entry_comments";
NSString * const HNWebsiteURLKey = @"HNWebSiteURLKey";

NSString * const HNFrontPageKey = @"front";
NSString * const HNBestPageKey = @"best";
NSString * const HNNewestPageKey = @"newest";

NSString * const HNWebsiteBaseURL = @"http://news.ycombinator.com";
NSString * const HNWebsitePlaceholderURL = @"http://news.ycombinator.com/%@";

CGFloat const HNDefaultTableCellHeight = 72.0f;
