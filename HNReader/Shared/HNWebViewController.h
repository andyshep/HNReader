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

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) HNEntry *entry;
@property (weak) NSURL *displayedURL;

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIBarButtonItem *readableButton;
@property (nonatomic, strong) NSMutableArray *items;

- (void)shouldLoadFromNotification:(NSNotification *)aNotification;

@end
