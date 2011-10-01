//
//  HNWebViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntry.h"
#import "HNReaderTheme.h"

@interface HNWebViewController : UIViewController <UIWebViewDelegate, UISplitViewControllerDelegate> {
    UIWebView *webView;
    HNEntry *entry;
    
    UIToolbar *toolbar;
    UIPopoverController *popoverController;
    NSMutableArray *items;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) HNEntry *entry;

@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSMutableArray *items;

@end
