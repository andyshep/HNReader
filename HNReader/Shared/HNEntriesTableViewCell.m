//
//  HNEntriesTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntriesTableViewCell.h"


@implementation HNEntriesTableViewCell

@synthesize siteTitleLabel, totalPointsLabel, siteDomainLabel;

- (id)init {
    if ((self = [super init])) {
        CGRect frame = CGRectMake(0.0f, 0.0f, 320.0f, 72.0f);
        UIView *containerView = [[[UIView alloc] initWithFrame:frame] autorelease];
        
        siteTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 4, 272, 40)];
        siteDomainLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 44, 162, 21)];
        totalPointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(204, 44, 80, 21)];
        
        siteTitleLabel.numberOfLines = 2;
        siteTitleLabel.font = [HNReaderTheme fourteenPointlabelFont];
        siteTitleLabel.adjustsFontSizeToFitWidth = YES;
        siteTitleLabel.backgroundColor = [UIColor clearColor];
        
        siteDomainLabel.font = [HNReaderTheme twelvePointlabelFont];
        siteDomainLabel.backgroundColor = [UIColor clearColor];
        siteDomainLabel.adjustsFontSizeToFitWidth = YES;
        siteDomainLabel.textColor = [UIColor grayColor];
        
        totalPointsLabel.font = [HNReaderTheme twelvePointlabelFont];
        totalPointsLabel.backgroundColor = [UIColor clearColor];
        totalPointsLabel.textColor = [UIColor grayColor];
        [totalPointsLabel setTextAlignment:UITextAlignmentRight];
        
        [containerView addSubview:siteTitleLabel];
        [containerView addSubview:siteDomainLabel];
        [containerView addSubview:totalPointsLabel];
        
        HNTableCellBackgroundView *backgroundView = [[HNTableCellBackgroundView alloc] initWithFrame:frame];
        [self setBackgroundView:backgroundView];
        [backgroundView release];
        
        HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:frame];
        [self setSelectedBackgroundView:selectedView];
        [selectedView release];
        
        [self addSubview:containerView];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return self;
}

- (void)dealloc {
    [siteTitleLabel release];
    [siteDomainLabel release];
    [totalPointsLabel release];
    [super dealloc];
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
