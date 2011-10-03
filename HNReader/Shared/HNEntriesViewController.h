//
//  HNEntriesViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderModel.h"
#import "HNReaderTheme.h"

#import "HNEntryViewController.h"
#import "HNWebViewController.h"

#import "HNEntriesTableViewCell.h"

@protocol HNEntriesViewControllerDelegate <NSObject>

- (void)shouldLoadURL:(NSURL *)aURL;

@end


@interface HNEntriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    HNReaderModel *model;
    
    UITableView *tableView;
	UISegmentedControl *entriesControl;
	UIToolbar *bottomToolbar;
    
    id<HNEntriesViewControllerDelegate> delegate;
}

@property (nonatomic, retain) HNReaderModel *model;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UISegmentedControl *entriesControl;
@property (nonatomic, retain) UIToolbar *bottomToolbar;

@property (assign) id<HNEntriesViewControllerDelegate> delegate;

- (void)loadEntries;

@end
