//
//  HNEntriesViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntriesViewController.h"


@implementation HNEntriesViewController

@synthesize model;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // TODO: title
        
        model = [[HNReaderModel alloc] init];
        
        [model addObserver:self 
                 forKeyPath:@"entries" 
                    options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                    context:@selector(entriesDidLoad)];
        
        [model addObserver:self 
                 forKeyPath:@"error" 
                    options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                    context:@selector(operationDidFail)];
        
        [self loadEntries];
    }
    return self;
}

- (void)dealloc {
    
    [model removeObserver:self forKeyPath:@"entries"];
    [model removeObserver:self forKeyPath:@"error"];
    [model release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	[[self navigationItem] setTitle:NSLocalizedString(@"Hacker News", @"Hacker News Entries")];
    [[[self navigationController] navigationBar] setTintColor:[UIColor colorWithRed:1 green:102.0/255.0 blue:0.0 alpha:1]];
    
    [self.tableView setBackgroundColor:[HNReaderTheme lightTanColor]];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadEntries)];
    [[self navigationItem] setRightBarButtonItem:refreshButton animated:YES];
    [refreshButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HNEntriesTableViewCell";
    
    HNEntriesTableViewCell *cell = (HNEntriesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HNEntry *selectedEntry = (HNEntry *)[model objectInEntriesAtIndex:[indexPath row]];
    
    HNEntryViewController *nextController = [[HNEntryViewController alloc] init];
    nextController.entry = selectedEntry;
    [self.navigationController pushViewController:nextController animated:YES];
}

#pragma mark - Model Observing and Reactions

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    SEL selector = (SEL)context;
    [self performSelector:selector];
}

- (void)loadEntries {
    [model requestEntries];
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
