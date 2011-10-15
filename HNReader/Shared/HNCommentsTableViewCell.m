//
//  HNCommentsTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNCommentsTableViewCell.h"

@implementation HNCommentsTableViewCell

@synthesize usernameLabel, timeLabel, commentTextLabel;

- (id)init {
    if ((self = [super init])) {
        CGRect cellContainerFrame = CGRectMake(0.0f, 0.0f, 320.0f, 72.0f);
        UIView *containerView = [[[UIView alloc] initWithFrame:cellContainerFrame] autorelease];
        
        usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 4.0f, 100.0f, 12.0f)];
        [usernameLabel setBackgroundColor:[UIColor clearColor]];
        [usernameLabel setFont:[HNReaderTheme tenPointlabelFont]];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(170.0f, 4.0f, 100.0f, 12.0f)];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setFont:[HNReaderTheme tenPointlabelFont]];
        
        commentTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 16.0f, 272.0f, 60.0f)];
        [commentTextLabel setBackgroundColor:[UIColor clearColor]];
        [commentTextLabel setFont:[HNReaderTheme twelvePointlabelFont]];
        [commentTextLabel setLineBreakMode:UILineBreakModeWordWrap];
        [commentTextLabel setNumberOfLines:0];
        
        HNTableCellBackgroundView *backgroundView = [[HNTableCellBackgroundView alloc] initWithFrame:cellContainerFrame];
        [self setBackgroundView:backgroundView];
        [backgroundView release];
        
        HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:cellContainerFrame];
        [self setSelectedBackgroundView:selectedView];
        [selectedView release];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [containerView addSubview:usernameLabel];
        [containerView addSubview:timeLabel];
        [containerView addSubview:commentTextLabel];
        [self addSubview:containerView];
    }

    return self;
}

- (void)dealloc {
    [usernameLabel release];
    [commentTextLabel release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
