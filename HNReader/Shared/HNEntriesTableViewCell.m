//
//  HNEntriesTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNEntriesTableViewCell.h"
#import "HNTableCellBackgroundView.h"


@implementation HNEntriesTableViewCell

@synthesize siteTitleLabel, commentsCountLabel, siteDomainLabel;

- (id)init {
    if ((self = [super init])) {
        UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 72)] autorelease];
        
        siteTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 4, 272, 40)];
        siteDomainLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 44, 162, 21)];
        commentsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(184, 44, 108, 21)];
        
        siteTitleLabel.numberOfLines = 2;
        siteTitleLabel.font = [HNReaderTheme fourteenPointlabelFont];
        siteTitleLabel.adjustsFontSizeToFitWidth = YES;
        siteTitleLabel.backgroundColor = [UIColor clearColor];
        
        siteDomainLabel.font = [HNReaderTheme twelvePointlabelFont];
        siteDomainLabel.backgroundColor = [UIColor clearColor];
        siteDomainLabel.adjustsFontSizeToFitWidth = YES;
        siteDomainLabel.textColor = [UIColor grayColor];
        
        commentsCountLabel.font = [HNReaderTheme twelvePointlabelFont];
        commentsCountLabel.backgroundColor = [UIColor clearColor];
        commentsCountLabel.textColor = [UIColor grayColor];
        
        [containerView addSubview:siteTitleLabel];
        [containerView addSubview:siteDomainLabel];
        [containerView addSubview:commentsCountLabel];
        
        HNTableCellBackgroundView *backgroundView = [[HNTableCellBackgroundView alloc] initWithFrame:CGRectMake(0, 0, 320, 72)];
        [self setBackgroundView:backgroundView];
        [backgroundView release];
        
        [self addSubview:containerView];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return self;
}

- (void)dealloc {
    [siteTitleLabel release];
    [siteDomainLabel release];
    [commentsCountLabel release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
