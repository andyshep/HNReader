//
//  HNEntriesDataSource.m
//  HNReader
//
//  Created by Andrew Shepard on 7/5/14.
//
//

#import "HNEntriesDataSource.h"
#import "HNEntriesModel.h"

#import "HNEntriesTableViewCell.h"
#import "HNEntry.h"

#import "HNConstants.h"

static void *myContext = &myContext;

@interface HNEntriesDataSource ()

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) HNEntriesModel *model;

@property (nonatomic, weak, readwrite) NSArray *entries;
@property (nonatomic, weak, readwrite) NSError *error;

@end

@implementation HNEntriesDataSource

-(instancetype)initWithTableView:(UITableView *)tableView {
    if (self = [super init]) {
        self.model = [[HNEntriesModel alloc] init];
        self.tableView = tableView;
        
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial;
        
        [self.model addObserver:self forKeyPath:@"error" options:options context:myContext];
        [self.model addObserver:self forKeyPath:@"entries" options:options context:myContext];
    }
    return self;
}

- (void)dealloc {
    [self.model removeObserver:self forKeyPath:@"entries"];
    [self.model removeObserver:self forKeyPath:@"error"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == myContext) {
        if ([keyPath isEqualToString:@"entries"]) {
            self.entries = self.model.entries;
        } else if ([keyPath isEqualToString:@"error"]) {
            self.error = self.model.error;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)loadEntriesForIndex:(NSUInteger)index {
    [self.model loadEntriesForIndex:index];
}

- (void)reloadEntriesForIndex:(NSUInteger)index {
    [self.model reloadEntriesForIndex:index];
}

#pragma mark - UITableView
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
    return self.model.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= self.model.entries.count) {
        return [tableView dequeueReusableCellWithIdentifier:HNLoadMoreTableViewCellIdentifier];
    } else {
        HNEntriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HNEntriesTableViewCellIdentifier];
        [self configureCell:cell forIndexPath:indexPath];
        return cell;
    }
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HNEntriesTableViewCell class]]) {
        HNEntriesTableViewCell *entryCell = (HNEntriesTableViewCell *)cell;
        HNEntry *entry = (HNEntry *)self.model.entries[indexPath.row];
        
        entryCell.siteTitleLabel.text = entry.title;
        entryCell.siteDomainLabel.text = entry.siteDomainURL;
        entryCell.totalPointsLabel.text = entry.totalPoints;
    }
}

@end
