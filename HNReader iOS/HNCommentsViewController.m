
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

static void *myContext = &myContext;

@interface HNCommentsViewController ()

@property (nonatomic, strong) HNCommentsDataSource *dataSource;

- (CGRect)sizeForString:(NSString *)string withIndentPadding:(NSInteger)padding;
- (void)handleContentSizeChangeNotification:(NSNotification *)notification;

@end

@implementation HNCommentsViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self.dataSource removeObserver:self forKeyPath:@"comments"];
    [self.dataSource removeObserver:self forKeyPath:@"error"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.entry != nil, @"HNEntry must be set by the time viewDidLoad is called");
    
    [self.navigationItem setLargeTitleDisplayMode:UINavigationItemLargeTitleDisplayModeNever];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeChangeNotification:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.dataSource = [[HNCommentsDataSource alloc] initWithTableView:self.tableView entry:self.entry];
    self.tableView.dataSource = self.dataSource;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0f;
    
    UINib *entryNib = [UINib nibWithNibName:HNEntriesTableViewCellIdentifier bundle:nil];
    [self.tableView registerNib:entryNib forCellReuseIdentifier:HNEntriesTableViewCellIdentifier];
    
    UINib *commentNib = [UINib nibWithNibName:HNCommentsTableViewCellIdentifier bundle:nil];
    [self.tableView registerNib:commentNib forCellReuseIdentifier:HNCommentsTableViewCellIdentifier];
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial;
    
    [self.dataSource addObserver:self forKeyPath:@"comments" options:options context:myContext];
    [self.dataSource addObserver:self forKeyPath:@"error" options:options context:myContext];
    
    // TODO: wire refresh button to selector
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView.visibleCells makeObjectsPerformSelector:@selector(setNeedsUpdateConstraints)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == myContext) {
        if ([keyPath isEqualToString:@"comments"]) {
            [self.tableView reloadData];
        } else if ([keyPath isEqualToString:@"error"]) {
            // TODO: present error
            NSLog(@"unhandled error: %@", self.dataSource.error);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        [self performSegueWithIdentifier:HNCommentsToWebSegueIdentifier sender:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *topViewController = [(UINavigationController *)segue.destinationViewController topViewController];
        if ([topViewController isKindOfClass:[HNWebViewController class]]) {
            HNWebViewController *nextController = (HNWebViewController *)topViewController;
            [nextController setEntry:self.entry];
        }
    }
}

- (CGRect)sizeForString:(NSString *)string withIndentPadding:(NSInteger)padding {
    return [string hn_frameForStringWithIndentPadding:padding];
}

- (void)handleContentSizeChangeNotification:(NSNotification *)notification {
    [self.tableView reloadData];
}

@end
