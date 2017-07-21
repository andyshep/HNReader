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

static void *myContext = &myContext;

@interface HNEntriesViewController ()

//@property (nonatomic, strong) HNEntriesTableViewCell *stubCell;

@property (nonatomic, strong) HNEntriesDataSource *dataSource;
//@property (nonatomic, assign) BOOL requestInProgress;

- (void)loadEntries;
- (void)handleContentSizeChangeNotification:(NSNotification *)notification;

@end

@implementation HNEntriesViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self.dataSource removeObserver:self forKeyPath:@"entries"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
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
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial;
    
    [self.dataSource addObserver:self forKeyPath:@"entries" options:options context:myContext];
    [self.dataSource addObserver:self forKeyPath:@"error" options:options context:myContext];
    
    [self.entriesControl addObserver:self forKeyPath:@"selectedSegmentIndex" options:options context:myContext];
    
    // TODO: wire up setup refresh button to selector
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == myContext) {
        if ([keyPath isEqualToString:@"entries"]) {
            [self entriesDidLoad];
        } else if ([keyPath isEqualToString:@"selectedSegmentIndex"]) {
            [self loadEntries];
        } else if ([keyPath isEqualToString:@"error"]) {
            // TODO: present error
            NSLog(@"unhandled error: %@", self.dataSource.error);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    static HNEntriesTableViewCell *stubCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stubCell = [tableView dequeueReusableCellWithIdentifier:HNEntriesTableViewCellIdentifier];
    });
    
    [self.dataSource configureCell:stubCell forIndexPath:indexPath];
    
    CGFloat height = [stubCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= self.dataSource.entries.count) {
        // TODO: call via to data source
//        [self.model loadMoreEntriesForIndex:[_entriesControl selectedSegmentIndex]];
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    }
    else {
        [self performSegueWithIdentifier:HNEntriesToCommentsSegueIdentifier sender:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[HNCommentsViewController class]]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        HNEntry *selectedEntry = (HNEntry *)self.dataSource.entries[indexPath.row];
        HNCommentsViewController *nextController = (HNCommentsViewController *)segue.destinationViewController;
        
        [nextController setEntry:selectedEntry];
    }
}

- (void)loadEntries {
//    if (_requestInProgress) {
//        return;
//    }
    
    [self prepareForRequest];
    [self.dataSource loadEntriesForIndex:[_entriesControl selectedSegmentIndex]];
}

- (void)reloadEntries {
//    if (_requestInProgress) {
//        return;
//    }
    
    [self prepareForRequest];
    [self.dataSource reloadEntriesForIndex:[_entriesControl selectedSegmentIndex]];
}

- (void)entriesDidLoad {
    // TODO: animate
//    self.requestInProgress = NO;
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
//    self.requestInProgress = YES;
    [self.tableView setUserInteractionEnabled:NO];
    [self.tableView setScrollEnabled:NO];
}

@end
