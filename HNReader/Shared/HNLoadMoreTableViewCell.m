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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_loadMoreLabel setTextAlignment:NSTextAlignmentCenter];
        [_loadMoreLabel setTextColor:[UIColor darkGrayColor]];
        [_loadMoreLabel setText:NSLocalizedString(@"Load More Entries...", @"Load More Entries table cell text")];
        
        [self.contentView addSubview:_loadMoreLabel];
        
        HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:CGRectZero];
        [self setSelectedBackgroundView:selectedView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.contentView.frame;
    
    [_loadMoreLabel setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(rect), 72.0f)];
}

@end
