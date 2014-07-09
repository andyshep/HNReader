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

//@property (nonatomic, strong) HNEntriesTableViewCell *stubCell;

@property (nonatomic, strong) HNEntriesDataSource *dataSource;
@property (nonatomic, assign) BOOL requestInProgress;

- (void)loadEntries;
- (void)handleContentSizeChangeNotification:(NSNotification *)notification;

@end

@implementation HNEntriesViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeChangeNotification:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.dataSource = [[HNEntriesDataSource alloc] initWithTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
    
    UINib *nib = [UINib nibWithNibName:HNEntriesTableViewCellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:HNEntriesTableViewCellIdentifier];
    
    NSAssert(self.entriesControl.numberOfSegments == 3, @"Entries control expects 3 segments");
    [self.navigationItem setTitle:NSLocalizedString(@"News", @"News Entries")];
    [self.entriesControl setTitle:NSLocalizedString(@"Front", @"Front") forSegmentAtIndex:0];
    [self.entriesControl setTitle:NSLocalizedString(@"Newest", @"Newest") forSegmentAtIndex:1];
    [self.entriesControl setTitle:NSLocalizedString(@"Best", @"Best") forSegmentAtIndex:2];

    // use resizing mask because control needs to support landscape
    [self.entriesControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
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
    
    self.refreshButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self reloadEntries];
        return [RACSignal empty];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    static HNEntriesTableViewCell *stubCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stubCell = [tableView dequeueReusableCellWithIdentifier:HNEntriesTableViewCellIdentifier];
    });
    
    [self.dataSource configureCell:stubCell forIndexPath:indexPath];
    stubCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 0.0f);
    
    [stubCell setNeedsLayout];
    [stubCell layoutIfNeeded];
    
    CGFloat height = [stubCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    UIAlertView *alert = [UIAlertView hn_alertViewWithError:self.dataSource.error];
    [alert show];
}

- (void)handleContentSizeChangeNotification:(NSNotification *)notification {
    // respond to preferred text size notifications changes and support dynamic type
    [self.tableView reloadData];
}

- (void)prepareForRequest {
    self.requestInProgress = YES;
    [self.tableView setUserInteractionEnabled:NO];
    [self.tableView setScrollEnabled:NO];
}

@end
