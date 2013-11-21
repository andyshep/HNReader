//
//  HNReaderAppDelegate_iPad.m
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNReaderAppDelegate_iPad.h"
#import "HNEntriesViewController.h"
#import "HNWebViewController.h"

@interface HNReaderAppDelegate_iPad ()

@property (nonatomic, strong) HNWebViewController *webViewController;

@end

@implementation HNReaderAppDelegate_iPad

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    self.webViewController = [[HNWebViewController alloc] init];
    
    self.entriesViewController = [[HNEntriesViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_entriesViewController];
    UINavigationController *webNavController = [[UINavigationController alloc] initWithRootViewController:_webViewController];
    
    [[navController navigationBar] setTintColor:[HNReaderTheme brightOrangeColor]];
    [[webNavController navigationBar] setTintColor:[HNReaderTheme brightOrangeColor]];
    
    self.splitViewController = [[UISplitViewController alloc] init];
    [_splitViewController setViewControllers:@[navController, webNavController]];
    
    [_entriesViewController setDelegate:_webViewController];
    [_splitViewController setDelegate:_webViewController];
    
    [self.window addSubview:[_splitViewController view]];
    
    [self.window setRootViewController:_splitViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
