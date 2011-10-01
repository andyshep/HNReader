//
//  HNWebViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNWebViewController.h"

@implementation HNWebViewController

@synthesize webView, entry;
@synthesize toolbar, popoverController, items;

- (id)init {
    if ((self = [super init])) {
        self.items = [NSMutableArray arrayWithCapacity:2];
    }
    
    return self;
}

- (void)dealloc {
    [webView release];
    [entry release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    self.view = contentView;
    
    webView = [[UIWebView alloc] initWithFrame:frame];
    [webView setScalesPageToFit:YES];
    [webView setDelegate:self];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:webView];
    [self.view setBackgroundColor:[HNReaderTheme lightTanColor]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // load a toolbar
        
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 44.0f)];
        [toolbar setTintColor:[HNReaderTheme brightOrangeColor]];
        
        [self.view addSubview:toolbar];
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:entry.linkURL]];
        [webView loadRequest:request];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    return YES;
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad:");
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    //barButtonItem.image = [UIImage imageNamed:@"flowering.png"];
	barButtonItem.title = @"News";
	barButtonItem.style = UIBarButtonItemStyleBordered;
	
	[self.items insertObject:barButtonItem atIndex:0];
	[toolbar setItems:self.items animated:YES];
	self.popoverController = pc;
}

- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	
	[self.items removeObjectAtIndex:0];
	[toolbar setItems:self.items animated:YES];
    popoverController = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController {

}

@end
