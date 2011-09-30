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

#import "HNEntriesTableViewCell.h"


@interface HNEntriesViewController : UITableViewController {
    HNReaderModel *model;
}

@property (nonatomic, retain) HNReaderModel *model;

- (void)loadEntries;

@end
