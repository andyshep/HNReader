//
//  HNLoadMoreTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 10/4/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNLoadMoreTableViewCell.h"

#import "HNTableCellBackgroundView.h"
#import "HNTableCellSelectedView.h"

@implementation HNLoadMoreTableViewCell

- (id)init {
    if ((self = [super init])) {
        self.loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_loadMoreLabel setTextAlignment:NSTextAlignmentCenter];
        [_loadMoreLabel setTextColor:[UIColor darkGrayColor]];
        [_loadMoreLabel setText:NSLocalizedString(@"Load More Entries...", @"Load More Entries table cell text")];
        
        [self.contentView addSubview:_loadMoreLabel];
        
        HNTableCellBackgroundView *backgroundView = [[HNTableCellBackgroundView alloc] initWithFrame:CGRectZero];
        [self setBackgroundView:backgroundView];
        
        HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:CGRectZero];
        [self setSelectedBackgroundView:selectedView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_loadMoreLabel setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 72.0f)];
}

@end
