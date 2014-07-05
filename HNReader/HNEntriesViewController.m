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

#import "HNWebViewController.h"
#import "HNCommentsViewController.h"

#import "HNEntriesTableViewCell.h"
#import "HNLoadMoreTableViewCell.h"

#import "HNConstants.h"
#import "UIColor+HNReaderTheme.h"

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

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSArray *items = @[NSLocalizedString(@"Front", @"Front"),
                           NSLocalizedString(@"Newest", @"Newest"),
                           NSLocalizedString(@"Best", @"Best")];
        
        self.entriesControl = [[UISegmentedControl alloc] initWithItems:items];
        [self.entriesControl setFrame:CGRectMake(0.0f, 0.0f, 287.0f, 30.0f)];
        [self.entriesControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.entriesControl setSelectedSegmentIndex:0];
    }
    return self;
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
    
//    NSArray *items = @[NSLocalizedString(@"Front", @"Front"),
//                       NSLocalizedString(@"Newest", @"Newest"),
//                       NSLocalizedString(@"Best", @"Best")];
//    
//    self.entriesControl = [[UISegmentedControl alloc] initWithItems:items];
//    [self.entriesControl setFrame:CGRectMake(0.0f, 0.0f, 287.0f, 30.0f)];
//    [self.entriesControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//    [self.entriesControl setSelectedSegmentIndex:0];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:self.entriesControl];
    [self.bottomToolbar setItems:@[buttonItem]];
    
    [self.bottomToolbar setTintColor:[UIColor hn_brightOrangeColor]];
    [self.entriesControl setTintColor:[UIColor hn_brightOrangeColor]];
    
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
    return HNDefaultTableCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= self.model.entries.count) {
        return [tableView dequeueReusableCellWithIdentifier:HNLoadMoreTableViewCellIdentifier];
    } else {
        HNEntriesTableViewCell *cell = (HNEntriesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:HNEntriesTableViewCellIdentifier];
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
        HNCommentsViewController *nextController = [storyboard instantiateViewControllerWithIdentifier:HNCommentsViewControllerIdentifier];
        [nextController setEntry:selectedEntry];
        [self.navigationController pushViewController:nextController animated:YES];
    }
}

- (void)loadEntries {
    if (_requestInProgress) {
        return;
    }
    
    [self prepareForRequest];
    [self.model loadEntriesForIndex:[_entriesControl selectedSegmentIndex]];
}

- (void)reloadEntries {
    if (_requestInProgress) {
        return;
    }
    
    [self prepareForRequest];
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

- (void)prepareForRequest {
    self.requestInProgress = YES;
    [self.tableView setUserInteractionEnabled:NO];
    [self.tableView setScrollEnabled:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.delegate shouldStopLoading];
    }
}

@end
