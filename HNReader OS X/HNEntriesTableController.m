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

#import "HNEntriesCellView.h"

#import "HNCommentsTableController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>

@interface HNEntriesTableController ()

@property (nonatomic, strong) HNEntriesModel *model;
@property (nonatomic, copy) NSArray *entries;

@end

@implementation HNEntriesTableController

- (instancetype)init {
    if (self = [super init]) {
        //
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.entries.count;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    HNEntry *entry = self.entries[row];

    HNEntriesCellView *cell = [tableView makeViewWithIdentifier:@"EntryCell" owner:tableView];
    cell.textField.stringValue = entry.title;

    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSUInteger row = [self.tableView selectedRow];
    HNEntry *entry = self.entries[row];
    
    [self.commentsController setEntry:entry];
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
    
    [self.entriesControl setTarget:self];
    [self.entriesControl setAction:@selector(selectedSegmentDidChange:)];
    
    [self.entriesControl setSelectedSegment:0];
    [self.model loadEntriesForIndex:0];
}

- (void)selectedSegmentDidChange:(id)sender {
    NSInteger index = self.entriesControl.selectedSegment;
    [self.model loadEntriesForIndex:index];
}

@end