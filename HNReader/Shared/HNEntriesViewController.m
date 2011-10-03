//
//  HNEntriesViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntriesViewController.h"


@implementation HNEntriesViewController

@synthesize model, tableView;
@synthesize entriesControl, bottomToolbar;
@synthesize delegate;

- (id)init {
    if ((self = [super init])) {
        
        model = [[HNReaderModel alloc] init];
        
        [model addObserver:self 
                forKeyPath:@"entries" 
                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                   context:@selector(entriesDidLoad)];
        
        [model addObserver:self 
                forKeyPath:@"error" 
                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                   context:@selector(operationDidFail)];
        
        self.delegate = nil;
    }
    
    return self;
}

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // TODO: title
//        
//        model = [[HNReaderModel alloc] init];
//        
//        [model addObserver:self 
//                 forKeyPath:@"entries" 
//                    options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
//                    context:@selector(entriesDidLoad)];
//        
//        [model addObserver:self 
//                 forKeyPath:@"error" 
//                    options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
//                    context:@selector(operationDidFail)];
//    }
//    return self;
//}

- (void)dealloc {
    
    [model removeObserver:self forKeyPath:@"entries"];
    [model removeObserver:self forKeyPath:@"error"];
    [model release];
    
    [tableView release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
    // CGRect rect = [[UIScreen mainScreen] bounds];
    CGRect frame = [self.view bounds];
    
    UIView *containerView = [[[UIView alloc] initWithFrame:frame] autorelease];
    
    // make the table
    CGRect tableFrame = CGRectMake(frame.origin.x, frame.origin.y, 320.0f, frame.size.height - 88.0f);
    
    tableView = [[UITableView alloc] initWithFrame:tableFrame];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    // make direction control
    NSArray *items = [NSArray arrayWithObjects:@"Front Page", @"Newest", @"Best", nil];
	entriesControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithArray:items]];
	entriesControl.segmentedControlStyle = UISegmentedControlStyleBar;
	entriesControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	entriesControl.frame = CGRectMake(0, 0, 305, 30);
	entriesControl.selectedSegmentIndex = 0;
    [entriesControl setTintColor:[HNReaderTheme brightOrangeColor]];
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:entriesControl];
    
    [entriesControl addTarget:self action:@selector(swapEntriesList:) forControlEvents:UIControlEventValueChanged];
    
//    // make bottom toolbar
//    CGRect toolbarFrame = CGRectMake(0, frame.size.height - 88.0f, 320.0f, 44.0f);
//    bottomToolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
//    [bottomToolbar setTintColor:[HNReaderTheme brightOrangeColor]];    
//    [bottomToolbar setItems:[NSArray arrayWithObjects:buttonItem, nil]];
    
    // [containerView addSubview:bottomToolbar];
    [containerView addSubview:tableView];
    
    [containerView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:containerView];
    
    // [[self navigationController] setToolbarHidden:NO];
    
    // [[[self navigationController] toolbar] setItems:[NSArray arrayWithObjects:buttonItem, nil]];
    
    [self setToolbarItems:[NSArray arrayWithObjects:buttonItem, nil]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[[self navigationItem] setTitle:NSLocalizedString(@"Hacker News", @"Hacker News Entries")];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadEntries)];
    [[self navigationItem] setRightBarButtonItem:refreshButton animated:YES];
    [refreshButton release];
    
    [self loadEntries];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [model countOfEntries];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72.0f;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HNEntriesTableViewCell";
    
    HNEntriesTableViewCell *cell = (HNEntriesTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HNEntriesTableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 72)];
    }
    
    HNEntry *aEntry = (HNEntry *)[model objectInEntriesAtIndex:[indexPath row]];
    
    // Configure the cell...
    cell.siteTitleLabel.text = aEntry.title;
    cell.siteDomainLabel.text = aEntry.siteDomainURL;
    cell.commentsCountLabel.text = aEntry.commentsCount;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HNEntry *selectedEntry = (HNEntry *)[model objectInEntriesAtIndex:[indexPath row]];
    
    //HNEntryViewController *nextController = [[HNEntryViewController alloc] init];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // push on a new web view
    
        HNWebViewController *nextController = [[HNWebViewController alloc] init];
        nextController.entry = selectedEntry;
        [self.navigationController pushViewController:nextController animated:YES];
        
        // TODO: implement this correctly
        // [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        // ask our delegate to load url
    
        // implement
        [self.delegate shouldLoadURL:[NSURL URLWithString:selectedEntry.linkURL]];
    }
}

//- (void)tableView:(UITableView *)aTableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
//}

#pragma mark - Model Observing and Reactions

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    SEL selector = (SEL)context;
    [self performSelector:selector];
}

- (void)loadEntries {
    [model loadEntriesForIndex:entriesControl.selectedSegmentIndex];
}

- (IBAction)swapEntriesList:(id)sender {
	// tell the model we're switching directions
	// [model_ loadStopsForTagIndex:self.directionControl.selectedSegmentIndex];
    [model loadEntriesForIndex:entriesControl.selectedSegmentIndex];
}

- (void)entriesDidLoad {
    // FIXME: only animate in the rows which are visible.
    int entriesToAdd = [model countOfEntries];
	int entriesToDelete = [self.tableView numberOfRowsInSection:0];
    
    [self.tableView beginUpdates];
	
	for (int i = 0; i < entriesToDelete; i++) {
		NSArray *delete = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]];
		[self.tableView deleteRowsAtIndexPaths:delete withRowAnimation:UITableViewRowAnimationBottom];
	}
    
    for (int i = 0; i < entriesToAdd; i++) {
		NSArray *insert = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]];
		[self.tableView insertRowsAtIndexPaths:insert withRowAnimation:UITableViewRowAnimationTop];
	}
    
    [self.tableView endUpdates];
}

- (void)operationDidFail {    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error alert view title") 
                                                    message:[[model error] localizedDescription] 
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"ok button title") 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
