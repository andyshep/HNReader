//
//  HNEntryViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNCommentsViewController.h"

@implementation HNCommentsViewController

@synthesize entry;

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        model = [[HNCommentsModel alloc] init];
        
        [model addObserver:self 
                forKeyPath:@"commentsInfo" 
                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                   context:@selector(commentsDidLoad)];
        
        [model addObserver:self 
                forKeyPath:@"error" 
                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
                   context:@selector(operationDidFail)];
    }
    
    return self;
}

- (void)dealloc {
    [entry release];
    
    [model removeObserver:self forKeyPath:@"commentsInfo"];
    [model removeObserver:self forKeyPath:@"error"];
    [model release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[[self navigationItem] setTitle:NSLocalizedString(@"Hacker News", @"Hacker News Entries")];
    
    [self.tableView setBackgroundColor:[HNReaderTheme lightTanColor]];
    
//    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadEntries)];
//    [[self navigationItem] setRightBarButtonItem:refreshButton animated:YES];
//    [refreshButton release];
    
    NSLog(@"%@", [entry description]);
    [model loadComments];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[model commentsInfo] objectForKey:@"entry_comments"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *_comments = (NSArray *)[[model commentsInfo] objectForKey:@"entry_comments"];
    HNComment *aComment = (HNComment *)[_comments objectAtIndex:[indexPath row]];
    
    CGSize textSize = [[aComment commentString] sizeWithFont:[UIFont systemFontOfSize:12.0f] forWidth:320.f lineBreakMode:UILineBreakModeCharacterWrap];

    // return textSize.height;
    return 72.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HNCommentsTableViewCell";
    
    HNCommentsTableViewCell *cell = (HNCommentsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // DTAttributedTextCell *cell = (DTAttributedTextCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[HNCommentsTableViewCell alloc] init];
        // cell = [[[DTAttributedTextCell alloc] initWithReuseIdentifier:CellIdentifier accessoryType:UITableViewCellAccessoryDisclosureIndicator] autorelease];
    }
    
    NSArray *_comments = (NSArray *)[[model commentsInfo] objectForKey:@"entry_comments"];
    HNComment *aComment = (HNComment *)[_comments objectAtIndex:[indexPath row]];

    float frameFudge = aComment.padding / 7.0f;
    
    CGRect usernameFrame = CGRectMake(10.0f + frameFudge, 4.0f, 272.0f - frameFudge, 8.0f);
    CGRect commentsFrame = CGRectMake(10.0f + frameFudge, 10.0f, 272.0f - frameFudge, 60.0f);
    
    // cell.attributedString = aComment.commentString;
    cell.usernameLabel.text = aComment.username;
    cell.commentTextLabel.text = aComment.commentString;
    [[cell commentTextLabel] setFrame:commentsFrame];
    [[cell usernameLabel] setFrame:usernameFrame];
    
    return cell;
}

#pragma mark - Model Observing and Reactions

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    SEL selector = (SEL)context;
    [self performSelector:selector];
}

- (void)commentsDidLoad {
    NSLog(@"commentsDidLoad:");
    
    NSLog(@"%@", [[model commentsInfo] valueForKey:@"entry_title"]);
    [self.tableView reloadData];
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

@end
