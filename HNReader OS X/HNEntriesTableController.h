//
//  HNEntriesTableController.h
//  HNReader
//
//  Created by Andrew Shepard on 11/27/14.
//
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface HNEntriesTableController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *entriesControl;

@end
