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

#define DEFAULT_CELL_HEIGHT 44.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@interface HNCommentsViewController ()

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
        
        [_model addObserver:self
                forKeyPath:@"commentsInfo" 
                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                   context:@selector(commentsDidLoad)];
        
        [_model addObserver:self
                forKeyPath:@"error" 
                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                   context:@selector(operationDidFail)];
    }
    
    return self;
}

- (void)dealloc {
    [_model removeObserver:self forKeyPath:@"commentsInfo"];
    [_model removeObserver:self forKeyPath:@"error"];
}

- (void)viewDidLoad {
    [[self navigationItem] setTitle:NSLocalizedString(@"News", @"News Entries")];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadComments)];
    [[self navigationItem] setRightBarButtonItem:refreshButton animated:YES];

    [_model loadComments];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_model cancelRequest];
    
    NSNotification *note = [NSNotification notificationWithName:@"HNStopLoadingNotification"
                                                          object:self 
                                                        userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // unselect the table cell, if need be.
    if ([_tableView indexPathForSelectedRow] != nil) {
        [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
    // support all orientation on the pad
    return YES;
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // first section is only the entry cell
    // second section is zero or more comment cells
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    return [[_model commentsInfo][@"entry_comments"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    // the entry cell is 72 pixels high
    if ([indexPath section] == 0) {
        return 72.0f;
    }
    // but we calcuate the height of each comment cell dynamically
    // based on the comment string height
    else {
        NSArray *comments = (NSArray *)[_model commentsInfo][@"entry_comments"];
        HNComment *comment = (HNComment *)comments[indexPath.row];
            
        CGRect commentTextRect = [self sizeForString:comment.commentString withIndentPadding:comment.padding];
        CGFloat height = MAX(commentTextRect.size.height, DEFAULT_CELL_HEIGHT);
        
        return height + (CELL_CONTENT_MARGIN * 2);
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        // return entry header cell
        static NSString *CellIdentifier = @"HNEntriesTableViewCell";
        
        HNEntriesTableViewCell *cell = (HNEntriesTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[HNEntriesTableViewCell alloc] init];
        }
        
        cell.siteTitleLabel.text = self.entry.title;
        cell.siteDomainLabel.text = self.entry.siteDomainURL;
        cell.totalPointsLabel.text = self.entry.totalPoints;
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"HNCommentsTableViewCell";
        
        HNCommentsTableViewCell *cell = (HNCommentsTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[HNCommentsTableViewCell alloc] init];
        }
        
        NSArray *comments = (NSArray *)[_model commentsInfo][@"entry_comments"];
        HNComment *comment = (HNComment *)comments[indexPath.row];
        
        CGRect commentTextRect = [self sizeForString:comment.commentString withIndentPadding:comment.padding];
        [[cell commentTextLabel] setFrame:commentTextRect];
        [[cell usernameLabel] setFrame:CGRectMake(commentTextRect.origin.x, 4.0f, commentTextRect.size.width, 12.0f)];
        
        cell.usernameLabel.text = comment.username;
        cell.commentTextLabel.text = comment.commentString;
        cell.timeLabel.text = comment.timeSinceCreation;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [_model cancelRequest];
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

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    SEL selector = (SEL)context;
    [self performSelector:selector];
}

- (void)commentsDidLoad {
    // TODO: animate
    [_tableView reloadData];
}

- (void)operationDidFail {    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error alert view title") 
                                                    message:[[_model error] localizedDescription]
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"ok button title") 
                                          otherButtonTitles:nil];
    [alert show];
}

- (NSArray *)indexPathsToInsert {
    NSMutableArray *_indexPaths = [NSMutableArray arrayWithCapacity:10];
    int count = [[_model commentsInfo][@"entry_comments"] count];
    
    for (int i = 0; i < count; i++) {
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_indexPaths addObject:_indexPath];
    }
    
    return [NSArray arrayWithArray:_indexPaths];
}

- (NSArray *)indexPathsToDelete {
    NSMutableArray *_indexPaths = [NSMutableArray arrayWithCapacity:10];
    int count = [_tableView numberOfRowsInSection:0];
    
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
    NSDictionary *extraInfo = @{@"kHNURL": urlString};
    NSNotification *aNote = [NSNotification notificationWithName:@"HNLoadSiteNotification" 
                                                          object:self userInfo:extraInfo];
    
    [[NSNotificationCenter defaultCenter] postNotification:aNote];
}

- (CGRect)sizeForString:(NSString *)string withIndentPadding:(NSInteger)padding {
    // knock the intentation padding down by a factor of 3
    // then adjust for cell margin and make sure the padding is even.  
    // otherwise the comment text is antialias'd
    padding = CELL_CONTENT_MARGIN + (padding / 3);
    if (padding % 2 != 0) {
        padding += 1;
    }
    
    int adjustedWidth = CELL_CONTENT_WIDTH - padding;
    if (adjustedWidth % 2 != 0) {
        adjustedWidth += 1.0f;
    }
    
    CGSize constraint = CGSizeMake(floorf(adjustedWidth) - (CELL_CONTENT_MARGIN * 2), 20000.0f);        
    CGSize size = [string sizeWithFont:[HNReaderTheme twelvePointlabelFont] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGRect commentTextRect = CGRectMake(padding, 
                                        CELL_CONTENT_MARGIN + 6, 
                                        adjustedWidth - CELL_CONTENT_MARGIN, 
                                        size.height);
    return commentTextRect;
}

@end
