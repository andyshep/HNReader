//
//  HNEntriesViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNEntriesViewController.h"

#import "HNEntry.h"
#import "HNEntriesModel.h"
#import "HNReaderTheme.h"

#import "HNWebViewController.h"
#import "HNCommentsViewController.h"

#import "HNEntriesTableViewCell.h"
#import "HNLoadMoreTableViewCell.h"

#define DEFAULT_CELL_HEIGHT 72.0f

@interface HNEntriesViewController ()

@property (nonatomic, strong) HNEntriesModel *model;
@property (nonatomic, assign) BOOL requestInProgress;

- (void)loadEntries;

- (NSArray *)indexPathsToInsert;
- (NSArray *)indexPathsToDelete;

@end

@implementation HNEntriesViewController

- (id)init {
    if ((self = [super initWithNibName:@"HNEntriesViewController" bundle:nil])) {
        self.model = [[HNEntriesModel alloc] init];
        
        [_model addObserver:self
                forKeyPath:@"entries" 
                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                   context:@selector(entriesDidLoad)];
        
        [_model addObserver:self
                forKeyPath:@"error" 
                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                   context:@selector(operationDidFail)];
        
        self.delegate = nil;
        self.requestInProgress = NO;
    }
    
    return self;
}

- (void)dealloc {
    [_model removeObserver:self forKeyPath:@"entries"];
    [_model removeObserver:self forKeyPath:@"error"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setTitle:NSLocalizedString(@"News", @"News Entries")];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadEntries)];
    [[self navigationItem] setRightBarButtonItem:refreshButton animated:YES];
    
    // make direction control
    NSArray *items = @[NSLocalizedString(@"Front Page", @"Front Page"), 
                      NSLocalizedString(@"Newest", @"Newest"), 
                      NSLocalizedString(@"Best", @"Best")];
    
	self.entriesControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithArray:items]];
    [_entriesControl setFrame:CGRectMake(0.0f, 0.0f, 305.0f, 30.0f)];
    [_entriesControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_entriesControl setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
    [_entriesControl setSelectedSegmentIndex:0];
    
    [_entriesControl addTarget:self action:@selector(loadEntries) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_entriesControl];
    [_bottomToolbar setItems:@[buttonItem]];
    
    [_bottomToolbar setTintColor:[HNReaderTheme brightOrangeColor]];
    [_entriesControl setTintColor:[HNReaderTheme brightOrangeColor]];
    
    [self loadEntries];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([_tableView indexPathForSelectedRow] != nil) {
        [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
    // support all orientation on the pad
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // if the entries are empty return 0
    // do not show a single 'load more..' row.
    if ([_model countOfEntries] <= 0) {
        return [_model countOfEntries];
    }
    
    // if we have the entries then show 'em
    // and plus one for the 'load more...' cell
    return [_model countOfEntries] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DEFAULT_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= [_model countOfEntries]) {
        static NSString *CellIdentifier = @"HNLoadMoreTableViewCell";
        
        // TODO: this should also be a custom cell
        // so you can give it a gradient and matching style.
        HNLoadMoreTableViewCell *cell = (HNLoadMoreTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[HNLoadMoreTableViewCell alloc] init];
        }
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"HNEntriesTableViewCell";
        
        HNEntriesTableViewCell *cell = (HNEntriesTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[HNEntriesTableViewCell alloc] init];
        }
        
        HNEntry *aEntry = (HNEntry *)[_model objectInEntriesAtIndex:indexPath.row];
        
        cell.siteTitleLabel.text = aEntry.title;
        cell.siteDomainLabel.text = aEntry.siteDomainURL;
        cell.totalPointsLabel.text = aEntry.totalPoints;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= [_model countOfEntries]) {
        // load more entries..
        [_model loadMoreEntriesForIndex:[_entriesControl selectedSegmentIndex]];
        [[aTableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    }
    else {
        HNEntry *selectedEntry = (HNEntry *)[_model objectInEntriesAtIndex:indexPath.row];
        HNCommentsViewController *nextController = [[HNCommentsViewController alloc] initWithEntry:selectedEntry];
        [self.navigationController pushViewController:nextController animated:YES];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    SEL selector = (SEL)context;
    [self performSelector:selector];
}

- (void)loadEntries {
    if (_requestInProgress) {
        return;
    }
    
    self.requestInProgress = YES;
    [_tableView setUserInteractionEnabled:NO];
    [_tableView setScrollEnabled:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.delegate shouldStopLoading];
    }
    
    [_model loadEntriesForIndex:[_entriesControl selectedSegmentIndex]];
}

- (void)reloadEntries {
    if (_requestInProgress) {
        return;
    }
    
    self.requestInProgress = YES;
    [_tableView setUserInteractionEnabled:NO];
    [_tableView setScrollEnabled:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.delegate shouldStopLoading];
    }
    
    [_model reloadEntriesForIndex:[_entriesControl selectedSegmentIndex]];
}

- (void)entriesDidLoad {
    // TODO: animate

    self.requestInProgress = NO;
    [_tableView reloadData];
    [_tableView setScrollEnabled:YES];
    [_tableView setUserInteractionEnabled:YES];
}

- (void)operationDidFail {    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                    message:[[_model error] localizedDescription]
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
                                          otherButtonTitles:nil];
    [alert show];
}

- (NSArray *)indexPathsToInsert {
    NSMutableArray *_indexPaths = [NSMutableArray arrayWithCapacity:10];
    int count = [_model countOfEntries];
    
    for (int i = 0; i < count; i++) {
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_indexPaths addObject:_indexPath];
    }
    
    return [NSArray arrayWithArray:_indexPaths];
}

- (NSArray *)indexPathsToDelete {
    NSMutableArray *_indexPaths = [NSMutableArray arrayWithCapacity:10];
    int count = [_tableView numberOfRowsInSection:0];
    
    for (int i = 0; i < count; i++) {
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_indexPaths addObject:_indexPath];
    }
    
    return [NSArray arrayWithArray:_indexPaths];
}

@end
