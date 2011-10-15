//
//  HNReaderAppDelegate_iPhone.m
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderAppDelegate_iPhone.h"

@implementation HNReaderAppDelegate_iPhone

@synthesize navController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    HNEntriesViewController *rootController = [[HNEntriesViewController alloc] init];
    navController = [[UINavigationController alloc] initWithRootViewController:rootController];
    [rootController release];
    
    // [navController setToolbarHidden:NO];
    [[navController navigationBar] setTintColor:[HNReaderTheme brightOrangeColor]];
    // [[navController toolbar] setTintColor:[HNReaderTheme brightOrangeColor]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    [self.window addSubview:navController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
