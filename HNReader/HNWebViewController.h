//
//  HNWebViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

@class HNEntry;

@interface HNWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) HNEntry *entry;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *readableButton;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end
