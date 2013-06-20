//
//  HNReaderAppDelegate_iPad.m
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderAppDelegate_iPad.h"

@implementation HNReaderAppDelegate_iPad

@synthesize splitViewController, entriesViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    entriesViewController = [[HNEntriesViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:entriesViewController];
    
    // [navController setToolbarHidden:NO];
    [[navController navigationBar] setTintColor:[HNReaderTheme brightOrangeColor]];
    // [[navController toolbar] setTintColor:[HNReaderTheme brightOrangeColor]];
    
    webViewController = [[HNWebViewController alloc] init];
    
    entriesViewController.delegate = webViewController;
    
    splitViewController = [[UISplitViewController alloc] init];
    splitViewController.viewControllers = @[navController, webViewController];
    splitViewController.delegate = webViewController;
    
    [self.window addSubview:splitViewController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
