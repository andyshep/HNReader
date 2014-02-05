//
//  HNCommentsTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNCommentsTableViewCell.h"
#import "HNTableCellSelectedView.h"
#import "HNCommentTools.h"

@implementation HNCommentsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_usernameLabel setBackgroundColor:[UIColor clearColor]];
        [_usernameLabel setTextColor:[UIColor lightGrayColor]];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setTextAlignment:NSTextAlignmentRight];
        [_timeLabel setTextColor:[UIColor lightGrayColor]];
        
        self.commentTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_commentTextLabel setBackgroundColor:[UIColor clearColor]];
        [_commentTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_commentTextLabel setNumberOfLines:0];
        
        [self.contentView addSubview:_usernameLabel];
        [self.contentView addSubview:_timeLabel];
        [self.contentView addSubview:_commentTextLabel];
        
        HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:CGRectZero];
        [self setSelectedBackgroundView:selectedView];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self setup];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = [HNCommentTools frameForString:self.commentTextLabel.text withIndentPadding:self.padding];
    [_usernameLabel setFrame:CGRectMake(CGRectGetMinX(rect), 4.0f, 100.0f, 15.0f)];
    [_timeLabel setFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 150.0f, 4.0f, 100.0f, 15.0f)];
    [_commentTextLabel setFrame:CGRectMake(CGRectGetMinX(rect), 20.0f, CGRectGetWidth(rect), CGRectGetHeight(rect))];
}

- (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setup];
}

- (void)setCommentText:(NSString *)commentText {
    self.commentTextLabel.text = commentText;
    [self setNeedsLayout];
}

- (void)setPadding:(NSInteger)padding {
    _padding = padding;
    [self setNeedsLayout];
}

- (void)setup {
    [_usernameLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    [_timeLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    [_commentTextLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
}

@end
