//
//  HNCommentsViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

@class HNEntry;
@class HNCommentsModel;

@interface HNCommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) HNEntry *entry;
@property (nonatomic, strong) HNCommentsModel *model;

- (id)initWithEntry:(HNEntry *)entry;

@end
