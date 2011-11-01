//
//  HNEntriesViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntriesViewController.h"

#define DEFAULT_CELL_HEIGHT 72.0f

@implementation HNEntriesViewController

@synthesize model, tableView;
@synthesize entriesControl, bottomToolbar;
@synthesize delegate;
@synthesize requestInProgress = _requestInProgress;

- (id)init {
    if ((self = [super initWithNibName:@"HNEntriesView" bundle:nil])) {
        
        model = [[HNEntriesModel alloc] init];
        
        [model addObserver:self 
                forKeyPath:@"entries" 
                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                   context:@selector(entriesDidLoad)];
        
        [model addObserver:self 
                forKeyPath:@"error" 
                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                   context:@selector(operationDidFail)];
        
        self.delegate = nil;
        self.requestInProgress = NO;
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
    // CGRect frame = [self.view bounds];
    
    [[self navigationItem] setTitle:NSLocalizedString(@"News", @"News Entries")];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadEntries)];
    [[self navigationItem] setRightBarButtonItem:refreshButton animated:YES];
    [refreshButton release];
    
    // make direction control
    NSArray *items = [NSArray arrayWithObjects:
                      NSLocalizedString(@"Front Page", @"Front Page"), 
                      NSLocalizedString(@"Newest", @"Newest"), 
                      NSLocalizedString(@"Best", @"Best"), 
                      nil];
	entriesControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithArray:items]];
	entriesControl.segmentedControlStyle = UISegmentedControlStyleBar;
	entriesControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	entriesControl.frame = CGRectMake(0, 0, 305, 30);
	entriesControl.selectedSegmentIndex = 0;
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:entriesControl];
    
    [entriesControl addTarget:self action:@selector(loadEntries) forControlEvents:UIControlEventValueChanged];
    
    [bottomToolbar setItems:[NSArray arrayWithObjects:buttonItem, nil]];
    [buttonItem release];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [bottomToolbar setTintColor:[HNReaderTheme brightOrangeColor]];
        [entriesControl setTintColor:[HNReaderTheme brightOrangeColor]];
    }
    else {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        // refactor and dry
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            [bottomToolbar setTintColor:[HNReaderTheme brightOrangeColor]];
            [entriesControl setTintColor:[HNReaderTheme brightOrangeColor]];
        }
        else {
            [bottomToolbar setTintColor:[HNReaderTheme veryDarkGrey]];
            [entriesControl setTintColor:[HNReaderTheme veryDarkGrey]];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadEntries];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([tableView indexPathForSelectedRow] != nil) {
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
    // support all orientation on the pad
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // if the entries are empty return 0
    // do not show a single 'load more..' row.
    if ([model countOfEntries] <= 0) {
        return [model countOfEntries];
    }
    
    // if we have the entries then show 'em
    // and plus one for the 'load more...' cell
    return [model countOfEntries] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DEFAULT_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] >= [model countOfEntries]) {
        static NSString *CellIdentifier = @"HNLoadMoreTableViewCell";
        
        // TODO: this should also be a custom cell
        // so you can give it a gradient and matching style.
        HNLoadMoreTableViewCell *cell = (HNLoadMoreTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[HNLoadMoreTableViewCell alloc] init] autorelease];
        }
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"HNEntriesTableViewCell";
        
        HNEntriesTableViewCell *cell = (HNEntriesTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[HNEntriesTableViewCell alloc] init] autorelease];
        }
        
        HNEntry *aEntry = (HNEntry *)[model objectInEntriesAtIndex:[indexPath row]];
        
        // Configure the cell...
        cell.siteTitleLabel.text = aEntry.title;
        cell.siteDomainLabel.text = aEntry.siteDomainURL;
        cell.totalPointsLabel.text = aEntry.totalPoints;
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath row] >= [model countOfEntries]) {
        // load more entries..
        [model loadMoreEntries];
        [[aTableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    }
    else {
        HNEntry *selectedEntry = (HNEntry *)[model objectInEntriesAtIndex:[indexPath row]];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            // push on a new web view
            
            // HNWebViewController *nextController = [[HNWebViewController alloc] init];
            HNCommentsViewController *nextController = [[HNCommentsViewController alloc] initWithEntry:selectedEntry];
            // nextController.entry = selectedEntry;
            [self.navigationController pushViewController:nextController animated:YES];
            [nextController release];
        }
        else {
            // ask our delegate to load url
            
            // implement
            // [self.delegate shouldLoadURL:[NSURL URLWithString:selectedEntry.linkURL]];
            
            HNCommentsViewController *nextController = [[HNCommentsViewController alloc] initWithEntry:selectedEntry];
            // nextController.entry = selectedEntry;
            [self.navigationController pushViewController:nextController animated:YES];
            [nextController release];
        }
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
    
    if (_requestInProgress) return;
    
    self.requestInProgress = YES;
    [tableView setUserInteractionEnabled:NO];
    [tableView setScrollEnabled:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [delegate shouldStopLoading];
    }
    
    [model loadEntriesForIndex:entriesControl.selectedSegmentIndex];
}

//- (IBAction)swapEntriesList:(id)sender {
//	// tell the model we're switching directions
//	// [model_ loadStopsForTagIndex:self.directionControl.selectedSegmentIndex];
//    [model loadEntriesForIndex:entriesControl.selectedSegmentIndex];
//}

- (void)entriesDidLoad {
//    // FIXME: only animate in the rows which are visible.
//    NSArray *indexPathsToInsert = [self indexPathsToInsert];
//    NSArray *indexPathsToDelete = [self indexPathsToDelete];
//    
//    UITableViewRowAnimation insertAnimation;
//    UITableViewRowAnimation deleteAnimation;
//    
//    if ([tableView numberOfRowsInSection:0] <= 0) {
//        insertAnimation = UITableViewRowAnimationTop;
//        deleteAnimation = UITableViewRowAnimationBottom;
//    }
//    else {
//        insertAnimation = UITableViewRowAnimationBottom;
//        deleteAnimation = UITableViewRowAnimationTop;
//    }
//    
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
//    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
//    [self.tableView endUpdates];

    self.requestInProgress = NO;
    [tableView reloadData];
    [tableView setScrollEnabled:YES];
    [tableView setUserInteractionEnabled:YES];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            // set tint color
            [bottomToolbar setTintColor:[HNReaderTheme brightOrangeColor]];
            [entriesControl setTintColor:[HNReaderTheme brightOrangeColor]];
        }
        else {
            // unset tint color
            [bottomToolbar setTintColor:[HNReaderTheme veryDarkGrey]];
            [entriesControl setTintColor:[HNReaderTheme veryDarkGrey]];
        }
    }
}

- (NSArray *)indexPathsToInsert {
    NSMutableArray *_indexPaths = [NSMutableArray arrayWithCapacity:10];
    int count = [model countOfEntries];
    
    for (int i = 0; i < count; i++) {
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_indexPaths addObject:_indexPath];
    }
    
    return [NSArray arrayWithArray:_indexPaths];
}

- (NSArray *)indexPathsToDelete {
    NSMutableArray *_indexPaths = [NSMutableArray arrayWithCapacity:10];
    int count = [tableView numberOfRowsInSection:0];
    
    for (int i = 0; i < count; i++) {
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_indexPaths addObject:_indexPath];
    }
    
    return [NSArray arrayWithArray:_indexPaths];
}

@end
