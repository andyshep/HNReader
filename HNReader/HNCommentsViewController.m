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

#import "HNCommentsDataSource.h"

#import "HNCommentsTableViewCell.h"
#import "HNEntriesTableViewCell.h"
#import "HNWebViewController.h"

#import "NSString+HNCommentTools.h"
#import "UIAlertView+HNAlertView.h"

@interface HNCommentsViewController ()

@property (nonatomic, strong) HNCommentsDataSource *dataSource;
//@property (nonatomic, strong) HNCommentsTableViewCell *stubCell;

- (CGRect)sizeForString:(NSString *)string withIndentPadding:(NSInteger)padding;
- (void)handleContentSizeChangeNotification:(NSNotification *)notification;

@end

@implementation HNCommentsViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.entry != nil, @"HNEntry must be set by the time viewDidLoad is called");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeChangeNotification:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.dataSource = [[HNCommentsDataSource alloc] initWithTableView:self.tableView entry:self.entry];
    self.tableView.dataSource = self.dataSource;
    
    UINib *nib = [UINib nibWithNibName:HNEntriesTableViewCellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:HNEntriesTableViewCellIdentifier];
    
    @weakify(self);
    [RACObserve(self.dataSource, comments) subscribeNext:^(id comments) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    [RACObserve(self.dataSource, error) subscribeNext:^(NSError *error) {
        if (error) {
            UIAlertView *alertView = [UIAlertView hn_alertViewWithError:error];
            [alertView show];
        }
    }];
    
    self.refreshButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.dataSource reloadComments];
        return [RACSignal empty];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView.visibleCells makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
}

#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    if ([indexPath section] == 0) {
        static HNEntriesTableViewCell *stubCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            stubCell = [tableView dequeueReusableCellWithIdentifier:HNEntriesTableViewCellIdentifier];
        });
        
        [self.dataSource configureEntryCell:stubCell];
        stubCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 0.0f);
        
        [stubCell setNeedsLayout];
        [stubCell layoutIfNeeded];
        
        CGFloat height = [stubCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height;
    } else {
        static HNCommentsTableViewCell *stubCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            stubCell = [tableView dequeueReusableCellWithIdentifier:HNCommentsTableViewCellIdentifier];
        });
        
        [self.dataSource configureCommentCell:stubCell forIndexPath:indexPath];
        stubCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 0.0f);
        
        [stubCell setNeedsLayout];
        [stubCell layoutIfNeeded];
        
        CGFloat height = [stubCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return HNDefaultTableCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        HNWebViewController *nextController = [storyboard instantiateViewControllerWithIdentifier:HNWebViewControllerIdentifier];
        [nextController setEntry:self.entry];
        [self.navigationController pushViewController:nextController animated:YES];
    }
}

- (CGRect)sizeForString:(NSString *)string withIndentPadding:(NSInteger)padding {
    return [string hn_frameForStringWithIndentPadding:padding];
}

- (void)handleContentSizeChangeNotification:(NSNotification *)notification {
    [self.tableView reloadData];
}

@end
