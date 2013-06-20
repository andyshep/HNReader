//
//  HNEntriesViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntriesModel.h"
#import "HNReaderTheme.h"

#import "HNWebViewController.h"
#import "HNCommentsViewController.h"

#import "HNEntriesTableViewCell.h"
#import "HNLoadMoreTableViewCell.h"

@interface HNEntriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    HNEntriesModel *model;
    
    IBOutlet UITableView *tableView;
    IBOutlet UIToolbar *bottomToolbar;
	UISegmentedControl *entriesControl;
    
    id<HNEntryLoaderDelegate> __weak delegate;
}

@property (nonatomic, strong) HNEntriesModel *model;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) UISegmentedControl *entriesControl;

@property (weak) id<HNEntryLoaderDelegate> delegate;
@property (assign) BOOL requestInProgress;

- (void)loadEntries;

- (NSArray *)indexPathsToInsert;
- (NSArray *)indexPathsToDelete;

@end
