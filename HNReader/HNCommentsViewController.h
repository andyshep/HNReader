//
//  HNCommentsViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

@class HNEntry;

@interface HNCommentsViewController : UIViewController <UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, strong) HNEntry *entry;

@end
