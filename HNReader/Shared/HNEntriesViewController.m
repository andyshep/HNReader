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

const CGFloat HNDefaultCellHeight = 72.0f;

@interface HNEntriesViewController ()

@property (nonatomic, strong) HNEntriesModel *model;
@property (nonatomic, assign) BOOL requestInProgress;

- (void)loadEntries;
- (NSArray *)indexPathsToInsert;
- (NSArray *)indexPathsToDelete;

@end

@implementation HNEntriesViewController

- (instancetype)init {
    if ((self = [super initWithNibName:@"HNEntriesViewController" bundle:nil])) {
        self.model = [[HNEntriesModel alloc] init];
        self.delegate = nil;
        self.requestInProgress = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setTitle:NSLocalizedString(@"News", @"News Entries")];
    
    [self.tableView registerClass:[HNEntriesTableViewCell class] forCellReuseIdentifier:@"HNEntriesTableViewCell"];
    [self.tableView registerClass:[HNLoadMoreTableViewCell class] forCellReuseIdentifier:@"HNLoadMoreTableViewCell"];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadEntries)];
    [[self navigationItem] setRightBarButtonItem:refreshButton animated:YES];
    
    // make direction control
    NSArray *items = @[NSLocalizedString(@"Top", @"Top"), NSLocalizedString(@"Newest", @"Newest"), NSLocalizedString(@"Best", @"Best")];
	self.entriesControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithArray:items]];
    [_entriesControl setFrame:CGRectMake(0.0f, 0.0f, 290.0f, 30.0f)];
    [_entriesControl setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
    
    [_entriesControl setSelectedSegmentIndex:0];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_entriesControl];
    [_bottomToolbar setItems:@[buttonItem]];
    
    [_bottomToolbar setTintColor:[HNReaderTheme brightOrangeColor]];
    [_entriesControl setTintColor:[HNReaderTheme brightOrangeColor]];
    
    @weakify(self);
    [RACObserve(self.model, entries) subscribeNext:^(NSArray *entries) {
        @strongify(self);
        [self entriesDidLoad];
    }];
    
    [RACObserve(self.model, error) subscribeNext:^(NSError *error) {
        @strongify(self);
        if (error) {
            [self operationDidFail];
        }
    }];
    
    [RACObserve(self.entriesControl, selectedSegmentIndex) subscribeNext:^(id x) {
        @strongify(self);
        [self loadEntries];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // if the entries are empty return 0
    // do not show a single 'load more..' row.
    if (self.model.entries.count <= 0) {
        return self.model.entries.count;
    }
    
    // if we have the entries then show
    // and plus one for the 'load more...' cell
    return self.model.entries.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return HNDefaultCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= self.model.entries.count) {
        return [tableView dequeueReusableCellWithIdentifier:@"HNLoadMoreTableViewCell"];
    } else {
        HNEntriesTableViewCell *cell = (HNEntriesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HNEntriesTableViewCell"];
        HNEntry *entry = (HNEntry *)self.model.entries[indexPath.row];
        
        cell.siteTitleLabel.text = entry.title;
        cell.siteDomainLabel.text = entry.siteDomainURL;
        cell.totalPointsLabel.text = entry.totalPoints;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= self.model.entries.count) {
        // load more entries..
        [_model loadMoreEntriesForIndex:[_entriesControl selectedSegmentIndex]];
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    }
    else {
        HNEntry *selectedEntry = (HNEntry *)self.model.entries[indexPath.row];
        HNCommentsViewController *nextController = [[HNCommentsViewController alloc] initWithEntry:selectedEntry];
        [self.navigationController pushViewController:nextController animated:YES];
    }
}

// TODO: refactor and cancel operations
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
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSUInteger count = self.model.entries.count;
    
    for (int i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    return [NSArray arrayWithArray:indexPaths];
}

- (NSArray *)indexPathsToDelete {
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSUInteger count = [_tableView numberOfRowsInSection:0];
    
    for (int i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    return [NSArray arrayWithArray:indexPaths];
}

@end
