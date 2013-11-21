//
//  HNReaderAppDelegate_iPhone.m
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNReaderAppDelegate_iPhone.h"
#import "HNEntriesViewController.h"

@implementation HNReaderAppDelegate_iPhone

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    HNEntriesViewController *entriesViewController = [[HNEntriesViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:entriesViewController];
    [[_navigationController navigationBar] setTintColor:[HNReaderTheme brightOrangeColor]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self.window addSubview:[_navigationController view]];
    
    [self.window setRootViewController:_navigationController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
