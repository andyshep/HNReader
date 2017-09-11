//
//  HNWebViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNWebViewController.h"

#import "HNEntry.h"
#import "HNConstants.h"

#import "readable.h"

@interface HNWebViewController ()

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSURL *displayedURL;
@property (nonatomic, assign) BOOL showReadableContent;

- (void)toggleReadableDisplay;

@end

@implementation HNWebViewController

- (void)setEntry:(HNEntry *)entry {
    if (_entry != entry) {
        _entry = entry;
        self.displayedURL = [NSURL URLWithString:_entry.linkURL];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.entry != nil, @"HNEntry must be set by the time viewDidLoad is called");
    NSAssert(self.displayedURL != nil, @"displayURL cannot be nil");
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.webView];
    
//    self.readableButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//        self.showReadableContent = !self.showReadableContent;
//        return [RACSignal empty];
//    }];
//    
//    [RACObserve(self, showReadableContent) subscribeNext:^(id x) {
//        [self toggleReadableDisplay];
//    }];
    
    [self loadHTMLContent];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.webView setFrame:self.view.bounds];
}

//- (void)viewDidDisappear:(BOOL)animated {
//    [self.webView stopLoading];
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//    
//    [super viewDidDisappear:animated];
//}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration animations:^{
        [self.webView setFrame:self.view.bounds];
    }];
}

#pragma mark - HTML and Readable Content Loading
- (void)toggleReadableDisplay {
    if (self.showReadableContent) {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor hn_brightOrangeColor]];
        [self loadReadableContent];
    } else {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor lightGrayColor]];
        [self loadHTMLContent];
    }
}

- (void)loadHTMLContent {
    if (!self.displayedURL) {
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.displayedURL];
    [self.webView loadRequest:request];
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)loadReadableContent {
    [self.webView evaluateJavaScript:@"document.body.innerHTML" completionHandler:^(id result, NSError *error) {
        NSString *html = (NSString *)result;
        const char *htmlContent = [html UTF8String];
        char *readableContent = readable(htmlContent, "", NULL, READABLE_OPTIONS_DEFAULT);
        
        if (readableContent != NULL) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"readable-formatting" ofType:@"html"];
            NSString *formattingTags = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSString *readableHTMLString = @(readableContent);
            NSString *html = [NSString stringWithFormat:@"%@%@", formattingTags, readableHTMLString];
            
            [self.webView loadHTMLString:html baseURL:self.displayedURL];
        } else {
            [self.navigationItem.rightBarButtonItem setTintColor:[UIColor lightGrayColor]];
            NSString *message = NSLocalizedString(@"Could not find any article content to display; not all webpages can be cleaned up into readable content.", @"");
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

@end
