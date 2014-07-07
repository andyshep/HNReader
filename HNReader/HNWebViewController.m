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

#import "UIAlertView+HNAlertView.h"

#import "readable.h"

@interface HNWebViewController ()

@property (nonatomic, strong) NSURL *displayedURL;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIPopoverController *popoverViewController;

@property (nonatomic, assign) BOOL showReadableContent;

@end

@implementation HNWebViewController

- (void)setEntry:(HNEntry *)entry {
    if (_entry != entry) {
        _entry = entry;
        self.displayedURL = [NSURL URLWithString:_entry.linkURL];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
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
    
    NSAssert(self.entry != nil, @"HNEntry must be set by the time viewDidLoad is called");
    NSAssert(self.displayedURL != nil, @"displayURL cannot be nil");
    
    [self.webView setFrame:self.view.frame];
    [self.view addSubview:self.webView];
    
    UIImage *image = [UIImage imageNamed:@"glasses.png"];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(toggleReadableDisplay:)];
    [button setTintColor:[UIColor blueColor]];
    [self.navigationItem setRightBarButtonItem:button];
    
    // TODO: reactive?
    [self loadHTMLContent];
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // https://discussions.apple.com/thread/1727260
    if (error.code == NSURLErrorCancelled) return;
    
    UIAlertView *alert = [UIAlertView hn_alertViewWithError:error];
    [alert show];
}

#pragma mark - HTML and Readable Content Loading
- (void)toggleReadableDisplay:(id)sender {
    self.showReadableContent = !self.showReadableContent;
    
    if (self.showReadableContent) {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor hn_brightOrangeColor]];
        [self loadReadableContent];
    } else {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor blueColor]];
        [self loadHTMLContent];
    }
}

- (void)loadHTMLContent {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.displayedURL];
    [self.webView loadRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)loadReadableContent {
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
    UIAlertView *alert = [UIAlertView hn_alertViewWithMessage:message];
    [alert show];
}

@end
