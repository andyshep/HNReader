//
//  HNEntriesTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNEntriesTableViewCell.h"
#import "HNTableCellSelectedView.h"

@interface HNEntriesTableViewCell ()

- (void)applyHighlightAndSelectionStyle:(BOOL)apply;

@end

@implementation HNEntriesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.siteTitleLabel setNumberOfLines:2];
    [self.siteTitleLabel setBackgroundColor:[UIColor clearColor]];
    
    HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:CGRectZero];
    [self setSelectedBackgroundView:selectedView];
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [self setup];
    
    [self.siteDomainLabel setAdjustsFontSizeToFitWidth:YES];
    [self.siteDomainLabel setBackgroundColor:[UIColor clearColor]];
    [self.siteDomainLabel setTextColor:[UIColor grayColor]];
    
    [self.totalPointsLabel setAdjustsFontSizeToFitWidth:YES];
    [self.totalPointsLabel setTextAlignment:NSTextAlignmentRight];
    [self.totalPointsLabel setBackgroundColor:[UIColor clearColor]];
    [self.totalPointsLabel setTextColor:[UIColor grayColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self applyHighlightAndSelectionStyle:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self applyHighlightAndSelectionStyle:highlighted];
}

- (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setup];
}

#pragma mark - Private
- (void)setup {
    [self.siteDomainLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [self.siteDomainLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    [self.totalPointsLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
}

- (void)applyHighlightAndSelectionStyle:(BOOL)apply {
    if (apply) {
        // apply styling for selection and highlight
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
