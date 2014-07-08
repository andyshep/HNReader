//
//  HNReaderAppDelegate.m
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNReaderAppDelegate.h"

@implementation HNReaderAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UINavigationBar appearance] setTintColor:[UIColor hn_brightOrangeColor]];
    [[UISegmentedControl appearanceWhenContainedIn:[UIToolbar class], nil] setTintColor:[UIColor hn_brightOrangeColor]];
    
    return YES;
}

@end
