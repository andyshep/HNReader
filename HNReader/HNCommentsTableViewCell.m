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

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
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
}

- (void)setPadding:(NSInteger)padding {
//    CGFloat adjustedPadding = 20.0f + floorf(padding * 0.33f);
//    self.leadingSpaceForCommentLabel.constant = adjustedPadding;
//    self.leadingSpaceForUsernameLabel.constant = adjustedPadding;
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)setup {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
//    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.usernameLabel setTextColor:[UIColor lightGrayColor]];
    [self.timeLabel setTextColor:[UIColor lightGrayColor]];
    [self.timeLabel setTextAlignment:NSTextAlignmentRight];
    [self.commentTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    
    [self.usernameLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    [self.timeLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    [self.commentTextLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
}

@end
