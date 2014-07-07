//
//  HNEntriesViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNEntriesViewController.h"
#import "HNCommentsViewController.h"

#import "HNEntriesTableViewCell.h"
#import "HNLoadMoreTableViewCell.h"

#import "HNEntry.h"
#import "HNEntriesDataSource.h"

#import "UIAlertView+HNAlertView.h"

@interface HNEntriesViewController ()

@property (nonatomic, strong) HNEntriesDataSource *dataSource;
@property (nonatomic, assign) BOOL requestInProgress;

- (void)loadEntries;
- (void)handleContentSizeChangeNotification:(NSNotification *)notification;

@end

@implementation HNEntriesViewController

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
    
    self.dataSource = [[HNEntriesDataSource alloc] initWithTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
    
    [self.navigationItem setTitle:NSLocalizedString(@"News", @"News Entries")];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeChangeNotification:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadEntries)];
    [self.navigationItem setRightBarButtonItem:refreshButton animated:YES];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:self.entriesControl];
    [self.bottomToolbar setItems:@[buttonItem]];
    
    [self.bottomToolbar setTintColor:[UIColor hn_brightOrangeColor]];
    [self.entriesControl setTintColor:[UIColor hn_brightOrangeColor]];
    
    @weakify(self);
    [RACObserve(self.dataSource, entries) subscribeNext:^(NSArray *entries) {
        @strongify(self);
        [self entriesDidLoad];
    }];
    
    [RACObserve(self.dataSource, error) subscribeNext:^(NSError *error) {
        if (error) {
            UIAlertView *alert = [UIAlertView hn_alertViewWithError:error];
            [alert show];
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
    // TODO: wtf is this?
//    [[self.tableView visibleCells] makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
    [[self.tableView visibleCells] makeObjectsPerformSelector:@selector(layoutIfNeeded)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return HNDefaultTableCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= self.dataSource.entries.count) {
        // TODO: call via to data source
//        [self.model loadMoreEntriesForIndex:[_entriesControl selectedSegmentIndex]];
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    }
    else {
        HNEntry *selectedEntry = (HNEntry *)self.dataSource.entries[indexPath.row];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
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
    [self.dataSource loadEntriesForIndex:[_entriesControl selectedSegmentIndex]];
}

- (void)reloadEntries {
    if (_requestInProgress) {
        return;
    }
    
    [self prepareForRequest];
    [self.dataSource reloadEntriesForIndex:[_entriesControl selectedSegmentIndex]];
}

- (void)entriesDidLoad {
    // TODO: animate

    self.requestInProgress = NO;
    [self.tableView reloadData];
    [self.tableView setScrollEnabled:YES];
    [self.tableView setUserInteractionEnabled:YES];
}

- (void)operationDidFail {
    NSString *message = self.dataSource.error.localizedDescription;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                    message:message
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)handleContentSizeChangeNotification:(NSNotification *)notification {
    // TODO: document
    [self.tableView reloadData];
}

- (void)prepareForRequest {
    self.requestInProgress = YES;
    [self.tableView setUserInteractionEnabled:NO];
    [self.tableView setScrollEnabled:NO];
}

@end
