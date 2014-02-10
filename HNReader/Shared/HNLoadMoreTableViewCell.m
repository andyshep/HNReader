//
//  HNLoadMoreTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 10/4/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNLoadMoreTableViewCell.h"
#import "HNTableCellSelectedView.h"

@implementation HNLoadMoreTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.loadMoreLabel setTextAlignment:NSTextAlignmentCenter];
    [self.loadMoreLabel setTextColor:[UIColor darkGrayColor]];
    [self.loadMoreLabel setText:NSLocalizedString(@"Load More Entries...", @"Load More Entries table cell text")];
    
    HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:CGRectZero];
    [self setSelectedBackgroundView:selectedView];
}

@end
