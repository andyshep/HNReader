//
//  HNCommentsViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntry.h"
#import "HNReaderTheme.h"

#import "HNCommentsModel.h"
#import "HNCommentsTableViewCell.h"
#import "HNEntriesTableViewCell.h"

#import "ShadowedTableView.h"

#import "HNWebViewController.h"

@interface HNCommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    HNEntry *entry;
    HNCommentsModel *model;
}

@property (nonatomic, strong) HNEntry *entry;
@property (nonatomic, strong) IBOutlet ShadowedTableView *tableView;

- (id)initWithEntry:(HNEntry *)aEntry;

- (void)loadComments;

- (NSArray *)indexPathsToInsert;
- (NSArray *)indexPathsToDelete;

- (void)postLoadSiteNotification;
- (CGRect)sizeForString:(NSString *)string withIndentPadding:(NSInteger)padding;

@end
