//
//  HNWebViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntry.h"
#import "HNReaderTheme.h"

#import "readable.h"
#import "AFHTTPRequestOperation.h"

@protocol HNEntryLoaderDelegate <NSObject>
- (void)shouldLoadURL:(NSURL *)aURL;
- (void)shouldStopLoading;
@end

@interface HNWebViewController : UIViewController <UIWebViewDelegate, UISplitViewControllerDelegate, HNEntryLoaderDelegate> {
    UIWebView *webView;
    HNEntry *entry;
    
    UIToolbar *toolbar;
    UIPopoverController *popoverController;
    UIBarButtonItem *readableButton;
    NSMutableArray *items;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) HNEntry *entry;
@property (assign) NSURL *displayedURL;

@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIBarButtonItem *readableButton;
@property (nonatomic, retain) NSMutableArray *items;

- (void)shouldLoadFromNotification:(NSNotification *)aNotification;

@end
