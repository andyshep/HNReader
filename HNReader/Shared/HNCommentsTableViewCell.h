//
//  HNCommentsTableViewCell.h
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderTheme.h"
#import "HNTableCellBackgroundView.h"
#import "HNTableCellSelectedView.h"

@interface HNCommentsTableViewCell : UITableViewCell {
    UILabel *usernameLabel;
    UILabel *commentTextLabel;
    UIView *containerView;
    CGRect cellContainerFrame;
}

@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, retain) UILabel *commentTextLabel;
@property (nonatomic, retain) UIView *containerView;
@property (assign) CGRect cellContainerFrame;

@end
