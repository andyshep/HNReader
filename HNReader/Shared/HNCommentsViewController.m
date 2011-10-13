//
//  HNCommentsViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNCommentsViewController.h"

#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation HNCommentsViewController

@synthesize entry, tableView;

- (id)initWithEntry:(HNEntry *)aEntry {
    if ((self = [super init])) {
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
    [tableView release];
    
    [model removeObserver:self forKeyPath:@"commentsInfo"];
    [model removeObserver:self forKeyPath:@"error"];
    [model release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[[self navigationItem] setTitle:NSLocalizedString(@"Hacker News", @"Hacker News Entries")];
    
    
    CGRect frame = [self.view bounds];
    tableView = [[ShadowedTableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 44.0f) style:UITableViewStylePlain];
    
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setBackgroundColor:[HNReaderTheme lightTanColor]];
    [self.view addSubview:tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // you end up loading comments twice...
    // temp fix.
    [model loadComments];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [model cancelRequest];
    
    NSNotification *aNote = [NSNotification notificationWithName:@"HNStopLoadingNotification" object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:aNote];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }
    
    return [[[model commentsInfo] objectForKey:@"entry_comments"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    
    if ([indexPath section] == 0) {
        return 72.0f;
    }
    else {
        NSArray *_comments = (NSArray *)[[model commentsInfo] objectForKey:@"entry_comments"];
        HNComment *aComment = (HNComment *)[_comments objectAtIndex:[indexPath row]];
        
        NSString *text = [aComment commentString];
        
        CGFloat padding = CELL_CONTENT_MARGIN + [aComment padding] / 3.0f;
        CGFloat adjustedWidth = CELL_CONTENT_WIDTH - padding;
        CGSize constraint = CGSizeMake(adjustedWidth - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[HNReaderTheme tenPointlabelFont] 
                       constrainedToSize:constraint 
                           lineBreakMode:UILineBreakModeWordWrap];
        CGFloat height = MAX(size.height, 44.0f);
        
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
        
        cell.siteTitleLabel.text = entry.title;
        cell.siteDomainLabel.text = entry.siteDomainURL;
        cell.totalPointsLabel.text = entry.totalPoints;
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"HNCommentsTableViewCell";
        
        HNCommentsTableViewCell *cell = (HNCommentsTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[HNCommentsTableViewCell alloc] init];
        }
        
        NSArray *_comments = (NSArray *)[[model commentsInfo] objectForKey:@"entry_comments"];
        HNComment *aComment = (HNComment *)[_comments objectAtIndex:[indexPath row]];
        
        NSString *text = [aComment commentString];
        
        CGFloat padding = CELL_CONTENT_MARGIN + [aComment padding] / 3.0f;
        CGFloat adjustedWidth = CELL_CONTENT_WIDTH - padding;
        CGSize constraint = CGSizeMake(adjustedWidth - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        
        CGSize size = [text sizeWithFont:[HNReaderTheme tenPointlabelFont] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        // TODO: should set timeLabel frmae too
        [[cell usernameLabel] setFrame:CGRectMake(padding, 4.0f, adjustedWidth, 12.0f)];
        [[cell commentTextLabel] setFrame:CGRectMake(padding, 
                                                     CELL_CONTENT_MARGIN + 6, 
                                                     adjustedWidth - (CELL_CONTENT_MARGIN * 2), 
                                                     MAX(size.height, 44.0f))];
        
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
        }
        else {
            // do somethign else for the pad
            // post a notification
            NSString *urlString = [[self entry] linkURL];
            NSDictionary *extraInfo = [NSDictionary dictionaryWithObject:urlString forKey:@"kHNURL"];
            NSNotification *aNote = [NSNotification notificationWithName:@"HNLoadSiteNotification" object:self userInfo:extraInfo];
            
            [[NSNotificationCenter defaultCenter] postNotification:aNote];
        }
    }
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

    [tableView reloadData];
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
    int count = [tableView numberOfRowsInSection:0];
    
    for (int i = 0; i < count; i++) {
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_indexPaths addObject:_indexPath];
    }
    
    return [NSArray arrayWithArray:_indexPaths];
}

@end
