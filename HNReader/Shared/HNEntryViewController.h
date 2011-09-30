//
//  HNEntryViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntry.h"
#import "HNReaderTheme.h"

@interface HNEntryViewController : UITableViewController {
    HNEntry *entry;
}

@property (assign) HNEntry *entry;

@end
