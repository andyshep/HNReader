//
//  HNCommentsTableController.h
//  HNReader
//
//  Created by Andrew Shepard on 11/29/14.
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@class HNEntry;

@interface HNCommentsTableController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) HNEntry *entry;

@end
