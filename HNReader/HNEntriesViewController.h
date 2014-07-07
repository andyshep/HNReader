//
//  HNEntriesViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

@class HNEntriesModel;

@interface HNEntriesViewController : UIViewController <UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) UISegmentedControl *entriesControl;

@end
