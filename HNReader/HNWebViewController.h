//
//  HNWebViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

@class HNEntry;

@protocol HNEntryLoaderDelegate <NSObject>

- (void)shouldLoadURL:(NSURL *)aURL;
- (void)shouldStopLoading;

@end

@interface HNWebViewController : UIViewController <UIWebViewDelegate, UISplitViewControllerDelegate, HNEntryLoaderDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *readableButton;

@property (nonatomic, strong) HNEntry *entry;

- (void)shouldLoadFromNotification:(NSNotification *)aNotification;

@end
