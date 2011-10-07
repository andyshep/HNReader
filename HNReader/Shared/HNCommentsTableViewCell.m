//
//  HNCommentsTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNCommentsTableViewCell.h"

@implementation HNCommentsTableViewCell

@synthesize usernameLabel, commentTextLabel;

- (id)init {
    if ((self = [super init])) {
        CGRect cellContainerFrame = CGRectMake(0.0f, 0.0f, 320.0f, 72.0f);
        UIView *containerView = [[[UIView alloc] initWithFrame:cellContainerFrame] autorelease];
        
        usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 272, 8)];
        [usernameLabel setBackgroundColor:[UIColor clearColor]];
        [usernameLabel setFont:[HNReaderTheme tenPointlabelFont]];
        
        commentTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 272, 60)];
        [commentTextLabel setBackgroundColor:[UIColor clearColor]];
        [commentTextLabel setFont:[HNReaderTheme tenPointlabelFont]];
        [commentTextLabel setLineBreakMode:UILineBreakModeWordWrap];
        [commentTextLabel setNumberOfLines:0];
        
        HNTableCellBackgroundView *backgroundView = [[HNTableCellBackgroundView alloc] initWithFrame:cellContainerFrame];
        [self setBackgroundView:backgroundView];
        [backgroundView release];
        
        HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:cellContainerFrame];
        [self setSelectedBackgroundView:selectedView];
        [selectedView release];
        
        [containerView addSubview:usernameLabel];
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
