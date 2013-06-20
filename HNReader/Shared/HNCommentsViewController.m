//
//  HNCommentsViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNCommentsViewController.h"

#define DEFAULT_CELL_HEIGHT 44.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation HNCommentsViewController

@synthesize entry;
@synthesize tableView = _tableView;

- (id)initWithEntry:(HNEntry *)aEntry {
    if ((self = [super initWithNibName:@"HNCommentsView" bundle:nil])) {
        model = [[HNCommentsModel alloc] initWithEntry:aEntry];
        
        [model addObserver:self 
                forKeyPath:@"commentsInfo" 
                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                   context:@selector(commentsDidLoad)];
        
        [model addObserver:self 
                forKeyPath:@"error" 
                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                   context:@selector(operationDidFail)];
        
        self.entry = aEntry;
    }
    
    return self;
}

- (void)dealloc {
    [entry release];
    [_tableView release];
    
    [model removeObserver:self forKeyPath:@"commentsInfo"];
    [model removeObserver:self forKeyPath:@"error"];
    [model release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [[self navigationItem] setTitle:NSLocalizedString(@"News", @"News Entries")];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadComments)];
    [[self navigationItem] setRightBarButtonItem:refreshButton animated:YES];
    [refreshButton release];

    [model loadComments];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [model cancelRequest];
    
    NSNotification *aNote = [NSNotification notificationWithName:@"HNStopLoadingNotification" 
                                                          object:self 
                                                        userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:aNote];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // first section is only the entry cell
    // second section is zero or more comment cells
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    return [[[model commentsInfo] objectForKey:@"entry_comments"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    // the entry cell is 72 pixels high
    if ([indexPath section] == 0) {
        return 72.0f;
    }
    // but we calcuate the height of each comment cell dynamically
    // based on the comment string height
    else {
        NSArray *_comments = (NSArray *)[[model commentsInfo] objectForKey:@"entry_comments"];
        HNComment *aComment = (HNComment *)[_comments objectAtIndex:[indexPath row]];
            
        CGRect commentTextRect = [self sizeForString:[aComment commentString] withIndentPadding:[aComment padding]];
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
            cell = [[[HNEntriesTableViewCell alloc] init] autorelease];
        }
        
        cell.siteTitleLabel.text = entry.title;
        cell.siteDomainLabel.text = entry.siteDomainURL;
        cell.totalPointsLabel.text = entry.totalPoints;
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"HNCommentsTableViewCell";
        
        HNCommentsTableViewCell *cell = (HNCommentsTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[HNCommentsTableViewCell alloc] init] autorelease];
        }
        
        NSArray *_comments = (NSArray *)[[model commentsInfo] objectForKey:@"entry_comments"];
        HNComment *aComment = (HNComment *)[_comments objectAtIndex:[indexPath row]];
        
        CGRect commentTextRect = [self sizeForString:[aComment commentString] withIndentPadding:[aComment padding]];
        [[cell commentTextLabel] setFrame:commentTextRect];
        [[cell usernameLabel] setFrame:CGRectMake(commentTextRect.origin.x, 4.0f, commentTextRect.size.width, 12.0f)];
        
        cell.usernameLabel.text = aComment.username;
        cell.commentTextLabel.text = aComment.commentString;
        cell.timeLabel.text = aComment.timeSinceCreation;
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath section] == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [model cancelRequest];
            HNWebViewController *nextController = [[HNWebViewController alloc] init];
            nextController.entry = [self entry];
            [[self navigationController] pushViewController:nextController animated:YES];
            [nextController release];
        }
        else {
            [self postLoadSiteNotification];
        }
    }
}

- (void)loadComments {
    [model loadComments];
}

#pragma mark - Model Observing and Reactions

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    SEL selector = (SEL)context;
    [self performSelector:selector];
}

- (void)commentsDidLoad {
//    // FIXME: only animate in the rows which are visible.
//    NSArray *indexPathsToInsert = [self indexPathsToInsert];
//    NSArray *indexPathsToDelete = [self indexPathsToDelete];
//    
//    UITableViewRowAnimation insertAnimation;
//    UITableViewRowAnimation deleteAnimation;
//    
//    if ([tableView numberOfRowsInSection:0] <= 0) {
//        insertAnimation = UITableViewRowAnimationTop;
//        deleteAnimation = UITableViewRowAnimationBottom;
//    }
//    else {
//        insertAnimation = UITableViewRowAnimationBottom;
//        deleteAnimation = UITableViewRowAnimationTop;
//    }
//    
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
//    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
//    [self.tableView endUpdates];

    [_tableView reloadData];
}

- (void)operationDidFail {    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error alert view title") 
                                                    message:[[model error] localizedDescription] 
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"ok button title") 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (NSArray *)indexPathsToInsert {
    NSMutableArray *_indexPaths = [NSMutableArray arrayWithCapacity:10];
    int count = [[[model commentsInfo] objectForKey:@"entry_comments"] count];
    
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
    NSDictionary *extraInfo = [NSDictionary dictionaryWithObject:urlString forKey:@"kHNURL"];
    NSNotification *aNote = [NSNotification notificationWithName:@"HNLoadSiteNotification" 
                                                          object:self userInfo:extraInfo];
    
    [[NSNotificationCenter defaultCenter] postNotification:aNote];
}

#pragma mark - HNCommentsTableViewCell height calculations

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
