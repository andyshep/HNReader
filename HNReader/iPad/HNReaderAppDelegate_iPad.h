//
//  HNReaderAppDelegate_iPad.h
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNReaderAppDelegate.h"

@class HNEntriesViewController;

@interface HNReaderAppDelegate_iPad : HNReaderAppDelegate

@property (nonatomic, strong) UISplitViewController *splitViewController;
@property (nonatomic, strong) HNEntriesViewController *entriesViewController;

@end
