//
//  HNCommentsTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNCommentsTableViewCell.h"

#import "HNTableCellSelectedView.h"

@implementation HNCommentsTableViewCell

- (id)init {
    if ((self = [super init])) {
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_usernameLabel setBackgroundColor:[UIColor clearColor]];
        [_usernameLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        [_usernameLabel setTextColor:[UIColor lightGrayColor]];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        [_timeLabel setTextAlignment:NSTextAlignmentRight];
        [_timeLabel setTextColor:[UIColor lightGrayColor]];
        
        self.commentTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_commentTextLabel setBackgroundColor:[UIColor clearColor]];
        [_commentTextLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
        [_commentTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_commentTextLabel setNumberOfLines:0];
        
        [self.contentView addSubview:_usernameLabel];
        [self.contentView addSubview:_timeLabel];
        [self.contentView addSubview:_commentTextLabel];
        
        HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:CGRectZero];
        [self setSelectedBackgroundView:selectedView];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.contentView.frame;
    
//    [_usernameLabel setFrame:CGRectMake(10.0f, 4.0f, 100.0f, 12.0f)];
    [_timeLabel setFrame:CGRectMake(CGRectGetWidth(rect) - 150.0f, 4.0f, 100.0f, 12.0f)];
//    [_commentTextLabel setFrame:CGRectMake(10.0f, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)]
    
}

@end
