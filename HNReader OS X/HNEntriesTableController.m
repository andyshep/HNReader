//
//  HNEntriesTableController.m
//  HNReader
//
//  Created by Andrew Shepard on 11/27/14.
//
//

#import "HNEntriesTableController.h"
#import "HNEntriesModel.h"
#import "HNEntry.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface HNEntriesTableController ()

@property (nonatomic, strong) HNEntriesModel *model;
@property (nonatomic, copy) NSArray *entries;

@end

@implementation HNEntriesTableController

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.entries.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    HNEntry *entry = self.entries[row];

    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"EntryCell" owner:self];
    cell.textField.stringValue = entry.title;
    
    return cell;
}

#pragma mark - Private
- (void)setup {
    self.model = [[HNEntriesModel alloc] init];
    
    [RACObserve(self.model, error) subscribeNext:^(id err) {
        NSLog(@"error: %@", err);
    }];
    
    [RACObserve(self.model, entries) subscribeNext:^(id x) {
        self.entries = self.model.entries;
        [self.tableView reloadData];
    }];
    
    [self.model loadEntriesForIndex:0];
}

@end
