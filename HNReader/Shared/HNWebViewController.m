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
#import "HNConstants.h"

#import "readable.h"

@interface HNWebViewController ()

@property (nonatomic, strong) NSURL *displayedURL;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIPopoverController *popoverViewController;

@end

@implementation HNWebViewController

- (instancetype)init {
    if ((self = [super init])) {
        self.items = [NSMutableArray array];
        self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [_webView setScalesPageToFit:YES];
        [_webView setDelegate:self];
        [_webView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.webView setFrame:self.view.frame];
    [self.view addSubview:self.webView];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIImage *image = [UIImage imageNamed:@"164-glasses-2.png"];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(makeReadable)];
        [[self navigationItem] setRightBarButtonItem:button];
        
        // WTF
        self.displayedURL = [NSURL URLWithString:[_entry linkURL]];
        [self shouldLoadURL:_displayedURL];
    } else {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldLoadFromNotification:) name:@"HNLoadSiteNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldStopLoading) name:HNStopLoadingNotification object:nil];
        
        UIImage *image = [UIImage imageNamed:@"163-glasses-1.png"];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(makeReadable)];

        [[self navigationItem] setRightBarButtonItem:button];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [super viewDidDisappear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration animations:^{
        [self.webView setFrame:self.view.bounds];
    }];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - UISplitViewController
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
	barButtonItem.title = NSLocalizedString(@"News", @"News popover title");
	barButtonItem.style = UIBarButtonItemStyleBordered;
    
    [[self navigationItem] setLeftBarButtonItem:barButtonItem];
	self.popoverViewController = pc;
}

- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [[self navigationItem] setLeftBarButtonItem:nil];
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
    NSURL *url = [NSURL URLWithString:extraInfo[HNWebSiteURLKey]];
    [self shouldLoadURL:url];
}

- (void)makeReadable {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.displayedURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *rawHtmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        const char *html_content = [rawHtmlString UTF8String];
        char *readable_content = readable(html_content, "", NULL, READABLE_OPTIONS_DEFAULT);
        
        if (readable_content != NULL) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"iphone-formatting" ofType:@"html"];
            NSString *formattingTags = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSString *readableHTMLString = @(readable_content);
            NSString *html = [NSString stringWithFormat:@"%@%@", formattingTags, readableHTMLString];
            
            [_webView loadHTMLString:html baseURL:self.displayedURL];
        } else {
            [self showReadableAlertWithError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
        [self showReadableAlertWithError:err];
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}

- (void)showReadableAlertWithError:(NSError *)error {
    NSString *message = NSLocalizedString(@"Could not find any article content to display; not all webpages can be cleaned up into readable content.", @"");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Whoops, sorry!", @"error")
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

@end
