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
    
    IBOutlet UITableView *tableView;
    IBOutlet UIToolbar *bottomToolbar;
	UISegmentedControl *entriesControl;
    
    id<HNEntriesViewControllerDelegate> delegate;
}

@property (nonatomic, retain) HNReaderModel *model;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, retain) UISegmentedControl *entriesControl;

@property (assign) id<HNEntriesViewControllerDelegate> delegate;

- (void)loadEntries;

@end
