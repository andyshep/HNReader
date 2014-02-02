//
//  HNCommentsViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNCommentsViewController.h"

#import "HNEntry.h"
#import "HNComment.h"
#import "HNCommentsModel.h"

#import "HNCommentsTableViewCell.h"
#import "HNEntriesTableViewCell.h"
#import "HNWebViewController.h"
#import "HNReaderTheme.h"

#import "HNCommentTools.h"

#define DEFAULT_CELL_HEIGHT 44.0f
#define CELL_CONTENT_MARGIN 20.0f

@interface HNCommentsViewController ()

@property (nonatomic, strong) HNEntry *entry;
@property (nonatomic, strong) HNCommentsModel *model;

- (void)loadComments;

- (NSArray *)indexPathsToInsert;
- (NSArray *)indexPathsToDelete;

- (void)postLoadSiteNotification;
- (CGRect)sizeForString:(NSString *)string withIndentPadding:(NSInteger)padding;

@end

@implementation HNCommentsViewController

- (id)initWithEntry:(HNEntry *)entry {
    if ((self = [super initWithNibName:@"HNCommentsViewController" bundle:nil])) {
        self.entry = entry;
        self.model = [[HNCommentsModel alloc] initWithEntry:entry];
    }
    
    return self;
}

- (void)viewDidLoad {
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadComments)];
    [[self navigationItem] setRightBarButtonItem:refreshButton animated:YES];

    [_model loadComments];
    
    [self.tableView registerClass:[HNEntriesTableViewCell class] forCellReuseIdentifier:@"HNEntriesTableViewCell"];
    [self.tableView registerClass:[HNCommentsTableViewCell class] forCellReuseIdentifier:@"HNCommentsTableViewCell"];
    
    @weakify(self);
    [RACObserve(self.model, comments) subscribeNext:^(id comments) {
        @strongify(self);
        [self commentsDidLoad];
    }];
    
    [RACObserve(self.model, error) subscribeNext:^(NSError *error) {
        @strongify(self);
        if (error) {
            [self operationDidFail];
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HNStopLoadingNotification" object:self userInfo:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // first section is only the entry cell
    // second section is zero or more comment cells
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    return [self.model.comments[@"entry_comments"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    // the entry cell is 72 pixels high
    if ([indexPath section] == 0) {
        return 72.0f;
    }
    // but we calcuate the height of each comment cell dynamically
    // based on the comment string height
    else {
        NSArray *comments = (NSArray *)self.model.comments[@"entry_comments"];
        HNComment *comment = (HNComment *)comments[indexPath.row];
            
        CGRect rect = [self sizeForString:comment.commentString withIndentPadding:comment.padding];
        CGFloat height = MAX(rect.size.height, DEFAULT_CELL_HEIGHT);
        
        return height + (CELL_CONTENT_MARGIN + 3.0f);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        HNEntriesTableViewCell *cell = (HNEntriesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HNEntriesTableViewCell"];
        
        cell.siteTitleLabel.text = self.entry.title;
        cell.siteDomainLabel.text = self.entry.siteDomainURL;
        cell.totalPointsLabel.text = self.entry.totalPoints;
        
        return cell;
    } else {
        HNCommentsTableViewCell *cell = (HNCommentsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HNCommentsTableViewCell"];
        NSArray *comments = (NSArray *)self.model.comments[@"entry_comments"];
        HNComment *comment = (HNComment *)comments[indexPath.row];
        
        [cell.usernameLabel setText:comment.username];
        [cell.timeLabel setText:comment.timeSinceCreation];
        [cell setCommentText:comment.commentString];
        [cell setPadding:comment.padding];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            HNWebViewController *nextController = [[HNWebViewController alloc] init];
            nextController.entry = [self entry];
            [[self navigationController] pushViewController:nextController animated:YES];
        }
        else {
            [self postLoadSiteNotification];
        }
    }
}

- (void)loadComments {
    [_model loadComments];
}

- (void)commentsDidLoad {
    [_tableView reloadData];
}

- (void)operationDidFail {    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error alert view title") 
                                                    message:[self.model.error localizedDescription]
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"ok button title") 
                                          otherButtonTitles:nil];
    [alert show];
}

- (NSArray *)indexPathsToInsert {
    NSMutableArray *_indexPaths = [NSMutableArray arrayWithCapacity:10];
    NSUInteger count = [self.model.comments[@"entry_comments"] count];
    for (int i = 0; i < count; i++) {
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_indexPaths addObject:_indexPath];
    }
    
    return [NSArray arrayWithArray:_indexPaths];
}

- (NSArray *)indexPathsToDelete {
    NSMutableArray *_indexPaths = [NSMutableArray arrayWithCapacity:10];
    NSUInteger count = [_tableView numberOfRowsInSection:0];
    for (int i = 0; i < count; i++) {
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_indexPaths addObject:_indexPath];
    }
    
    return [NSArray arrayWithArray:_indexPaths];
}

- (void)postLoadSiteNotification {
    // post a notification that a site should be loaded
    // the web view will respond to this notification and load the site
    // this is for the pad only.  on the phone, the vc is pushed onto stack
    NSString *urlString = [[self entry] linkURL];
    NSDictionary *userInfo = @{@"kHNURL": urlString};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HNLoadSiteNotification" object:self userInfo:userInfo];
}

- (CGRect)sizeForString:(NSString *)string withIndentPadding:(NSInteger)padding {
    return [HNCommentTools frameForString:string withIndentPadding:padding];
}

@end
