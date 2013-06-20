//
//  HNReaderAppDelegate_iPad.h
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderAppDelegate.h"
#import "HNEntriesViewController.h"
#import "HNWebViewController.h"

@interface HNReaderAppDelegate_iPad : HNReaderAppDelegate {
    UISplitViewController *splitViewController;
    
    HNEntriesViewController *entriesViewController;
    HNWebViewController *webViewController;
}

@property (nonatomic, strong) UISplitViewController *splitViewController;
@property (nonatomic, strong) HNEntriesViewController *entriesViewController;

@end
