//
//  HNEntriesViewController.h
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntriesModel.h"
#import "HNReaderTheme.h"

#import "HNWebViewController.h"
#import "HNCommentsViewController.h"

#import "HNEntriesTableViewCell.h"
#import "HNLoadMoreTableViewCell.h"

#import "ShadowedTableView.h"

typedef enum  {
    HNLoadingNewEntriesStateIdentifier,
    HNLoadingMoreEntriesStateIdentifier,
    HNLoadingIdleState
} HNEntryLoadingStateIdentifier;

@protocol HNEntriesViewControllerDelegate <NSObject>

- (void)shouldLoadURL:(NSURL *)aURL;
- (void)shouldStopLoading;

@end


@interface HNEntriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    HNEntriesModel *model;
    
    IBOutlet ShadowedTableView *tableView;
    IBOutlet UIToolbar *bottomToolbar;
	UISegmentedControl *entriesControl;
    
    id<HNEntriesViewControllerDelegate> delegate;
    
    HNEntryLoadingStateIdentifier loadingState;
}

@property (nonatomic, retain) HNEntriesModel *model;
@property (nonatomic, retain) IBOutlet ShadowedTableView *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, retain) UISegmentedControl *entriesControl;

@property (assign) id<HNEntriesViewControllerDelegate> delegate;

- (void)loadEntries;

- (NSArray *)indexPathsToInsert;
- (NSArray *)indexPathsToDelete;

@end
