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
        
        [RACObserve(self.model, error) subscribeNext:^(id x) {
            self.error = self.model.error;
        }];
        
        [RACObserve(self.model, entries) subscribeNext:^(id x) {
            self.entries = self.model.entries;
        }];
    }
    return self;
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
