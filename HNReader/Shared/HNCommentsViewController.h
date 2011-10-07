//
//  HNEntryViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntry.h"
#import "HNReaderTheme.h"

#import "HNCommentsModel.h"
#import "HNCommentsTableViewCell.h"
// #import "DTAttributedTextCell.h"

// #import "NSAttributedString+HTML.h"

@interface HNCommentsViewController : UITableViewController {
    HNEntry *entry;
    HNCommentsModel *model;
}

@property (nonatomic, retain) HNEntry *entry;

@end
