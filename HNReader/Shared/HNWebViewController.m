//
//  HNWebViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNWebViewController.h"

#import "AFHTTPRequestOperation.h"
#import "HNEntry.h"
#import "readable.h"

@interface HNWebViewController ()

@property (nonatomic, strong) NSURL *displayedURL;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIPopoverController *popoverViewController;

@end

@implementation HNWebViewController

- (id)init {
    if ((self = [super init])) {
        self.items = [NSMutableArray arrayWithCapacity:2];
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [_webView setScalesPageToFit:YES];
        [_webView setDelegate:self];
        [_webView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        
//        self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
//        [_toolbar setTintColor:[HNReaderTheme brightOrangeColor]];
//        [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    [super loadView];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    
    [_webView setFrame:frame];
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        // load a toolbar for our splitview (pad only)
//
//        [_toolbar setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 44.0f)];
//        [_webView setFrame:CGRectMake(frame.origin.x, 44.0f, frame.size.width, frame.size.height - 44.0f)];
//        [contentView addSubview:_toolbar];
//    }
    
    [contentView addSubview:_webView];
    [self.view addSubview:contentView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"webView: %@", NSStringFromCGRect(self.webView.frame));
    
    [self.webView setFrame:self.view.bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIImage *image = [UIImage imageNamed:@"164-glasses-2.png"];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(makeReadable)];
        [[self navigationItem] setRightBarButtonItem:button];
        
        // WTF
        self.displayedURL = [NSURL URLWithString:[_entry linkURL]];
        [self shouldLoadURL:_displayedURL];
    } else {
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(shouldLoadFromNotification:) name:@"HNLoadSiteNotification" object:nil];
        [defaultCenter addObserver:self selector:@selector(shouldStopLoading) name:@"HNStopLoadingNotification" object:nil];
        
        UIImage *image = [UIImage imageNamed:@"163-glasses-1.png"];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(makeReadable)];

        [[self navigationItem] setRightBarButtonItem:button];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [_webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - UISplitViewController
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
	barButtonItem.title = NSLocalizedString(@"News", @"News popover title");
	barButtonItem.style = UIBarButtonItemStyleBordered;
	
//	[self.items insertObject:barButtonItem atIndex:0];
    
    [[self navigationItem] setLeftBarButtonItem:barButtonItem];
    
    // don't use animation so there isn't a ui artifact when launching in landscape
    // really don't need it here since this is called during rotations
//	[_toolbar setItems:self.items animated:NO];
	self.popoverViewController = pc;
}

- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    [[self navigationItem] setLeftBarButtonItem:nil];
    
    // don't use animation so there isn't a ui artifact when launching in landscape
    // really don't need it here since this is called during rotations
//	[_toolbar setItems:self.items animated:NO];
    self.popoverViewController = nil;
}

#pragma mark - HNEntriesViewControllerDelegate
- (void)shouldLoadURL:(NSURL *)aURL {
    self.displayedURL = aURL;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_displayedURL];
    [_webView loadRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)shouldStopLoading {
    [_webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // empty out the webview
    // http://lists.apple.com/archives/cocoa-dev/2010/Nov/msg00680.html
    // [webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // https://discussions.apple.com/thread/1727260
    if (error.code == NSURLErrorCancelled) return;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error alert view title") 
                                                    message:[error localizedDescription] 
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"ok button title") 
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)shouldLoadFromNotification:(NSNotification *)aNotification {
    NSDictionary *extraInfo = [aNotification userInfo];
    NSString *aURLString = extraInfo[@"kHNURL"];
    NSURL *aURL = [NSURL URLWithString:aURLString];
    
    [self shouldLoadURL:aURL];
}

- (void)makeReadable {
    NSURL *aURL = _displayedURL;
    NSURLRequest *request = [NSURLRequest requestWithURL:aURL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *rawHtmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        const char *html_content = [rawHtmlString UTF8String];
        char *readable_content = readable(html_content, "", NULL, READABLE_OPTIONS_DEFAULT);
        
        if (readable_content != NULL) {
            
            // FIXME: cache teh file paths...
            NSString *filePath = nil;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                
                // if this is a phone, we have a smaller screen
                // so add the meta tag to specify the viewport
                // 28 px is also too big for phone
                filePath = [[NSBundle mainBundle] pathForResource:@"iphone-formatting" ofType:@"html"];
            }
            else {
                filePath = [[NSBundle mainBundle] pathForResource:@"ipad-formatting" ofType:@"html"];
            }
            
            NSString *formattingTags = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSString *readableHTMLString = @(readable_content);
            NSString *html = [NSString stringWithFormat:@"%@%@", formattingTags, readableHTMLString];
            
            [_webView loadHTMLString:html baseURL:aURL];
        }
        
        // NSLog(@"succuess: %@", [NSString stringWithCString:readable_content encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
        NSString *message = NSLocalizedString(@"Could not find readable content on the page", @"Could not find readable content on the page.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error")
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}

@end
