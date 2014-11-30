//
//  HNCommentsTableController.m
//  HNReader
//
//  Created by Andrew Shepard on 11/29/14.
//
//

#import "HNCommentsTableController.h"

#import "HNCommentsModel.h"
#import "HNComment.h"

#import "HNConstants.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>

@interface HNCommentsTableController ()

@property (nonatomic, strong) HNCommentsModel *model;
@property (nonatomic, strong) NSDictionary *comments;

@end

@implementation HNCommentsTableController

- (void)setEntry:(HNEntry *)entry {
    if (_entry != entry) {
        _entry = entry;
        
        self.model = [[HNCommentsModel alloc] initWithEntry:entry];
        
        [RACObserve(self.model, comments) subscribeNext:^(id comments) {
            self.comments = comments;
            [self.tableView reloadData];
        }];
        
        [_model loadComments];
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.comments[HNEntryCommentsKey] count];
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    HNComment *comment = [self.comments[HNEntryCommentsKey] objectAtIndex:row];
    
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"CommentCell" owner:tableView];
    cell.textField.stringValue = comment.commentString;
    
    return cell;
}

@end
