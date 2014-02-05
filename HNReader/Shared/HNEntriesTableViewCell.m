//
//  HNEntriesTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNEntriesTableViewCell.h"

#import "HNTableCellSelectedView.h"

@implementation HNEntriesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.siteTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_siteTitleLabel setNumberOfLines:2];
        [_siteTitleLabel setAdjustsFontSizeToFitWidth:YES];
        [_siteTitleLabel setBackgroundColor:[UIColor clearColor]];
        
        self.siteDomainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_siteDomainLabel setAdjustsFontSizeToFitWidth:YES];
        [_siteDomainLabel setBackgroundColor:[UIColor clearColor]];
        [_siteDomainLabel setTextColor:[UIColor grayColor]];
        
        self.totalPointsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_totalPointsLabel setTextAlignment:NSTextAlignmentRight];
        [_totalPointsLabel setBackgroundColor:[UIColor clearColor]];
        [_totalPointsLabel setTextColor:[UIColor grayColor]];
        
        [self.contentView addSubview:_siteTitleLabel];
        [self.contentView addSubview:_siteDomainLabel];
        [self.contentView addSubview:_totalPointsLabel];
        
        HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:CGRectZero];
        [self setSelectedBackgroundView:selectedView];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        [self setup];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.contentView.frame;
    [_siteTitleLabel setFrame:CGRectMake(10.0f, 4.0f, CGRectGetWidth(rect) - 10.0f, 40.0f)];
    [_siteDomainLabel setFrame:CGRectMake(10.0f, 44.0f, CGRectGetWidth(rect) - 100.0f, 21.0f)];
    [_totalPointsLabel setFrame:CGRectMake(CGRectGetWidth(rect) - 110.0f, 44.0f, 95.0f, 21.0f)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
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

- (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setup];
}

- (void)setup {
    [_siteTitleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [_siteDomainLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    [_totalPointsLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
}

@end
