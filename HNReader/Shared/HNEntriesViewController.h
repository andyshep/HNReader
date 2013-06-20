//
//  HNEntriesViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

@class HNEntriesModel;

@protocol HNEntryLoaderDelegate;

@interface HNEntriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) UISegmentedControl *entriesControl;

@property (nonatomic, weak) id<HNEntryLoaderDelegate> delegate;

@end
