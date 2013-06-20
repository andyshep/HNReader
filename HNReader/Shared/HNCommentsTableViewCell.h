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
    UILabel *timeLabel;
    UILabel *commentTextLabel;
}

@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *commentTextLabel;

@end
