//
//  HNReaderAppDelegate_iPhone.h
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderAppDelegate.h"
#import "HNEntriesViewController.h"


@interface HNReaderAppDelegate_iPhone : HNReaderAppDelegate {
    UINavigationController *navController;
}

@property (nonatomic, strong) UINavigationController *navController;

@end
