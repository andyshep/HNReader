//
//  HNReaderAppDelegate_iPad.m
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderAppDelegate_iPad.h"

@implementation HNReaderAppDelegate_iPad

@synthesize splitViewController, navController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    entriesViewController = [[HNEntriesViewController alloc] init];
    navController = [[UINavigationController alloc] initWithRootViewController:entriesViewController];
    
    [[navController navigationBar] setTintColor:[HNReaderTheme brightOrangeColor]];
    
    webViewController = [[HNWebViewController alloc] init];
    
    splitViewController = [[UISplitViewController alloc] init];
    splitViewController.viewControllers = [NSArray arrayWithObjects:navController, webViewController, nil];
    splitViewController.delegate = webViewController;
    
    [self.window addSubview:splitViewController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
