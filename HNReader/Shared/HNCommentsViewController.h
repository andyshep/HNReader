//
//  HNCommentsViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntry.h"
#import "HNReaderTheme.h"

#import "HNCommentsModel.h"
#import "HNCommentsTableViewCell.h"

@interface HNCommentsViewController : UITableViewController {
    HNEntry *entry;
    HNCommentsModel *model;
}

@property (nonatomic, retain) HNEntry *entry;

- (id)initWithEntry:(HNEntry *)aEntry;

- (NSString *)formatBodyText:(NSString *)bodyText;
- (CGFloat)heightForBodyText:(NSString *)text withWidth:(CGFloat)width indentationLevel:(int)indentationLevel;

@end
