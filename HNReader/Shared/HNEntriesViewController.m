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
- (void)handleContentSizeChangeNotification:(NSNotification *)notification;

@end

@implementation HNEntriesViewController

- (HNEntriesModel *)model {
    if (!_model) {
        _model = [[HNEntriesModel alloc] init];
    }
    
    return _model;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setTitle:NSLocalizedString(@"News", @"News Entries")];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeChangeNotification:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadEntries)];
    [[self navigationItem] setRightBarButtonItem:refreshButton animated:YES];
    
    [self.entriesControl setTitle:NSLocalizedString(@"Top", @"Top") forSegmentAtIndex:0];
    [self.entriesControl setTitle:NSLocalizedString(@"Newest", @"Newest") forSegmentAtIndex:1];
    [self.entriesControl setTitle:NSLocalizedString(@"Best", @"Best") forSegmentAtIndex:2];
    [self.entriesControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_entriesControl setSelectedSegmentIndex:0];
    
    [self.bottomToolbar setTintColor:[HNReaderTheme brightOrangeColor]];
    [self.entriesControl setTintColor:[HNReaderTheme brightOrangeColor]];
    
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    [[self.tableView visibleCells] makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
    [[self.tableView visibleCells] makeObjectsPerformSelector:@selector(layoutIfNeeded)];
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
        [self.model loadMoreEntriesForIndex:[_entriesControl selectedSegmentIndex]];
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    }
    else {
        HNEntry *selectedEntry = (HNEntry *)self.model.entries[indexPath.row];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:nil];
        HNCommentsViewController *nextController = [storyboard instantiateViewControllerWithIdentifier:@"HNCommentsViewController"];
        [nextController setEntry:selectedEntry];
        [self.navigationController pushViewController:nextController animated:YES];
    }
}

// TODO: refactor and cancel operations
- (void)loadEntries {
    if (_requestInProgress) {
        return;
    }
    
    self.requestInProgress = YES;
    [self.tableView setUserInteractionEnabled:NO];
    [self.tableView setScrollEnabled:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.delegate shouldStopLoading];
    }
    
    [self.model loadEntriesForIndex:[_entriesControl selectedSegmentIndex]];
}

- (void)reloadEntries {
    if (_requestInProgress) {
        return;
    }
    
    self.requestInProgress = YES;
    [self.tableView setUserInteractionEnabled:NO];
    [self.tableView setScrollEnabled:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.delegate shouldStopLoading];
    }
    
    [self.model reloadEntriesForIndex:[_entriesControl selectedSegmentIndex]];
}

- (void)entriesDidLoad {
    // TODO: animate

    self.requestInProgress = NO;
    [self.tableView reloadData];
    [self.tableView setScrollEnabled:YES];
    [self.tableView setUserInteractionEnabled:YES];
}

- (void)operationDidFail {    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                    message:[[_model error] localizedDescription]
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)handleContentSizeChangeNotification:(NSNotification *)notification {
    [self.tableView reloadData];
}

@end
