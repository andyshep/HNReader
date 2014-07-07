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

@property (nonatomic, strong) HNEntry *entry;
@property (nonatomic, strong) NSURL *displayedURL;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIPopoverController *popoverViewController;

@property (nonatomic, assign) BOOL showReadableContent;

@end

@implementation HNWebViewController

- (instancetype)initWithEntry:(HNEntry *)entry {
    if ((self = [super init])) {
        self.items = [NSMutableArray array];
        self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [self.webView setScalesPageToFit:YES];
        [self.webView setDelegate:self];
        [self.webView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        
        self.showReadableContent = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.webView setFrame:self.view.frame];
    [self.view addSubview:self.webView];
    
    UIImage *image = [UIImage imageNamed:@"glasses.png"];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(makeReadable)];
    [button setTintColor:[UIColor redColor]];
    [self.navigationItem setRightBarButtonItem:button];
    
    self.displayedURL = [NSURL URLWithString:self.entry.linkURL];
    [self shouldLoadURL:self.displayedURL];
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

#pragma mark - HNEntriesViewControllerDelegate
- (void)shouldLoadURL:(NSURL *)url {
    self.displayedURL = url;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.displayedURL];
    [self.webView loadRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)shouldStopLoadingURL {
    [self.webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // empty out the webview
    // http://lists.apple.com/archives/cocoa-dev/2010/Nov/msg00680.html
    // [webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
}

#pragma mark - Readable
- (void)makeReadable {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.displayedURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *rawHtmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        const char *html_content = [rawHtmlString UTF8String];
        char *readable_content = readable(html_content, "", NULL, READABLE_OPTIONS_DEFAULT);
        
        if (readable_content != NULL) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"readable-formatting" ofType:@"html"];
            NSString *formattingTags = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSString *readableHTMLString = @(readable_content);
            NSString *html = [NSString stringWithFormat:@"%@%@", formattingTags, readableHTMLString];
            
            [self.webView loadHTMLString:html baseURL:self.displayedURL];
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
