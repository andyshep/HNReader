//
//  HNCommentsTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNCommentsTableViewCell.h"

#import "HNTableCellBackgroundView.h"
#import "HNTableCellSelectedView.h"

@implementation HNCommentsTableViewCell

- (id)init {
    if ((self = [super init])) {
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_usernameLabel setBackgroundColor:[UIColor clearColor]];
        [_usernameLabel setFont:[HNReaderTheme tenPointlabelFont]];
        [_usernameLabel setTextColor:[UIColor lightGrayColor]];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setFont:[HNReaderTheme tenPointlabelFont]];
        [_timeLabel setTextAlignment:NSTextAlignmentRight];
        [_timeLabel setTextColor:[UIColor lightGrayColor]];
        
        self.commentTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_commentTextLabel setBackgroundColor:[UIColor clearColor]];
        [_commentTextLabel setFont:[HNReaderTheme twelvePointlabelFont]];
        [_commentTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_commentTextLabel setNumberOfLines:0];
        
        [self.contentView addSubview:_usernameLabel];
        [self.contentView addSubview:_timeLabel];
        [self.contentView addSubview:_commentTextLabel];
        
        HNTableCellBackgroundView *backgroundView = [[HNTableCellBackgroundView alloc] initWithFrame:CGRectZero];
        [self setBackgroundView:backgroundView];
        
        HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:CGRectZero];
        [self setSelectedBackgroundView:selectedView];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_usernameLabel setFrame:CGRectMake(10.0f, 4.0f, 100.0f, 12.0f)];
    [_timeLabel setFrame:CGRectMake(180.0f, 4.0f, 115.0f, 12.0f)];
}

@end
