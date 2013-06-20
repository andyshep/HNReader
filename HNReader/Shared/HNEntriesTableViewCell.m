//
//  HNEntriesTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNEntriesTableViewCell.h"

#import "HNTableCellBackgroundView.h"
#import "HNTableCellSelectedView.h"

@implementation HNEntriesTableViewCell

- (id)init {
    if ((self = [super init])) {
        self.siteTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_siteTitleLabel setNumberOfLines:2];
        [_siteTitleLabel setFont:[HNReaderTheme fourteenPointlabelFont]];
        [_siteTitleLabel setAdjustsFontSizeToFitWidth:YES];
        [_siteTitleLabel setBackgroundColor:[UIColor clearColor]];
        
        self.siteDomainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_siteDomainLabel setAdjustsFontSizeToFitWidth:YES];
        [_siteDomainLabel setFont:[HNReaderTheme twelvePointlabelFont]];
        [_siteDomainLabel setBackgroundColor:[UIColor clearColor]];
        [_siteDomainLabel setTextColor:[UIColor grayColor]];
        
        self.totalPointsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_totalPointsLabel setTextAlignment:NSTextAlignmentRight];
        [_totalPointsLabel setFont:[HNReaderTheme twelvePointlabelFont]];
        [_totalPointsLabel setBackgroundColor:[UIColor clearColor]];
        [_totalPointsLabel setTextColor:[UIColor grayColor]];
        
        [self.contentView addSubview:_siteTitleLabel];
        [self.contentView addSubview:_siteDomainLabel];
        [self.contentView addSubview:_totalPointsLabel];
        
        HNTableCellBackgroundView *backgroundView = [[HNTableCellBackgroundView alloc] initWithFrame:CGRectZero];
        [self setBackgroundView:backgroundView];
        
        HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:CGRectZero];
        [self setSelectedBackgroundView:selectedView];
        
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_siteTitleLabel setFrame:CGRectMake(20.0f, 4.0f, 272.0f, 40.0f)];
    [_siteDomainLabel setFrame:CGRectMake(20.0f, 44.0f, 162.0f, 21.0f)];
    [_totalPointsLabel setFrame:CGRectMake(204.0f, 44.0f, 80.0f, 21.0f)];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.siteTitleLabel.textColor = [UIColor whiteColor];
        self.siteDomainLabel.textColor = [UIColor whiteColor];
        self.totalPointsLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.siteTitleLabel.textColor = [UIColor blackColor];
        self.siteDomainLabel.textColor = [UIColor grayColor];
        self.totalPointsLabel.textColor = [UIColor grayColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.siteTitleLabel.textColor = [UIColor whiteColor];
        self.siteDomainLabel.textColor = [UIColor whiteColor];
        self.totalPointsLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.siteTitleLabel.textColor = [UIColor blackColor];
        self.siteDomainLabel.textColor = [UIColor grayColor];
        self.totalPointsLabel.textColor = [UIColor grayColor];
    }
}

@end
