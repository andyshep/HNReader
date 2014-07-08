//
//  HNCommentsDataSource.m
//  HNReader
//
//  Created by Andrew Shepard on 7/6/14.
//
//

#import "HNCommentsDataSource.h"

#import "HNCommentsModel.h"
#import "HNEntry.h"
#import "HNComment.h"

#import "HNEntriesTableViewCell.h"
#import "HNCommentsTableViewCell.h"

@interface HNCommentsDataSource ()

@property (nonatomic, weak, readwrite) NSDictionary *comments;
@property (nonatomic, weak, readwrite) NSError *error;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) HNCommentsModel *model;
@property (nonatomic, strong) HNEntry *entry;

@end

@implementation HNCommentsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView entry:(HNEntry *)entry {
    if (self = [super init]) {
        self.tableView = tableView;
        self.entry = entry;
        self.model = [[HNCommentsModel alloc] initWithEntry:self.entry];
        
        [RACObserve(self.model, comments) subscribeNext:^(id comments) {
            self.comments = comments;
        }];
        
        [RACObserve(self.model, error) subscribeNext:^(NSError *error) {
            self.error = error;
        }];
        
        [self reloadComments];
    }
    return self;
}

- (void)reloadComments {
    [self.model loadComments];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // first section is only the entry cell
    // second section is zero or more comment cells
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return [self.model.comments[HNEntryCommentsKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        HNEntriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HNEntriesTableViewCellIdentifier];
        
        cell.siteTitleLabel.text = self.entry.title;
        cell.siteDomainLabel.text = self.entry.siteDomainURL;
        cell.totalPointsLabel.text = self.entry.totalPoints;
        
        return cell;
    } else {
        HNCommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HNCommentsTableViewCellIdentifier];
        [self configureCommentCell:cell forIndexPath:indexPath];
        
        return cell;
    }
}

- (void)configureCommentCell:(HNCommentsTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSArray *comments = (NSArray *)self.model.comments[HNEntryCommentsKey];
    HNComment *comment = (HNComment *)comments[indexPath.row];
    
    [cell.usernameLabel setText:comment.username];
    [cell.timeLabel setText:comment.timeSinceCreation];
    [cell setCommentText:comment.commentString];
    [cell setPadding:comment.padding];
}

@end
