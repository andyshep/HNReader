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
    ShadowedTableView *tableView;
}

@property (nonatomic, retain) HNEntry *entry;
@property (nonatomic, retain) ShadowedTableView *tableView;

- (id)initWithEntry:(HNEntry *)aEntry;

- (NSArray *)indexPathsToInsert;
- (NSArray *)indexPathsToDelete;

@end
