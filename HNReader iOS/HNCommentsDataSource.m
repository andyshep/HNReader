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

static void *myContext = &myContext;

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
        
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial;
        
        [self.model addObserver:self forKeyPath:@"comments" options:options context:myContext];
        [self.model addObserver:self forKeyPath:@"error" options:options context:myContext];
        
        [self reloadComments];
    }
    return self;
}

- (void)dealloc {
    [self.model removeObserver:self forKeyPath:@"comments"];
    [self.model removeObserver:self forKeyPath:@"error"];
}

- (void)reloadComments {
    [self.model loadComments];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == myContext) {
        if ([keyPath isEqualToString:@"comments"]) {
            self.comments = self.model.comments;
        } else if ([keyPath isEqualToString:@"error"]) {
            self.error = self.model.error;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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
        [self configureCell:cell forIndexPath:indexPath];
        
        return cell;
    } else {
        HNCommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HNCommentsTableViewCellIdentifier];
        [self configureCell:cell forIndexPath:indexPath];
        
        return cell;
    }
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HNEntriesTableViewCell class]]) {
        HNEntriesTableViewCell *entryCell = (HNEntriesTableViewCell *)cell;
        entryCell.siteTitleLabel.text = self.entry.title;
        entryCell.siteDomainLabel.text = self.entry.siteDomainURL;
        entryCell.totalPointsLabel.text = self.entry.totalPoints;
    }
    else if ([cell isKindOfClass:[HNCommentsTableViewCell class]]) {
        HNCommentsTableViewCell *commentsCell = (HNCommentsTableViewCell *)cell;
        NSArray *comments = (NSArray *)self.model.comments[HNEntryCommentsKey];
        HNComment *comment = (HNComment *)comments[indexPath.row];
        
        [commentsCell.usernameLabel setText:comment.username];
        [commentsCell.timeLabel setText:comment.timeSinceCreation];
        [commentsCell setCommentText:comment.commentString];
        [commentsCell setPadding:comment.padding];
    }
}

@end
