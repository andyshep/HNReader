//
//  AppDelegate.m
//  HNReader OSX
//
//  Created by Andrew Shepard on 11/22/14.
//
//

#import "AppDelegate.h"

static const CGFloat kHNSplitViewMaxWidth = 420.0f;
static const CGFloat kHNSplitViewMinWidth = 256.0f;

@interface AppDelegate () <NSSplitViewDelegate>

@property (nonatomic, weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - NSSplitViewDelegate

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0) {
        return (proposedMinimumPosition > kHNSplitViewMinWidth) ? proposedMinimumPosition : kHNSplitViewMinWidth;
    }
    
    return proposedMinimumPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0) {
        return (proposedMaximumPosition < kHNSplitViewMaxWidth) ? proposedMaximumPosition : kHNSplitViewMaxWidth;
    }
    
    return proposedMaximumPosition;
}

@end
