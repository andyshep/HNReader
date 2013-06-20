//
//  HNLoadMoreTableViewCell.h
//  HNReader
//
//  Created by Andrew Shepard on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderTheme.h"
#import "HNTableCellBackgroundView.h"
#import "HNTableCellSelectedView.h"

@interface HNLoadMoreTableViewCell : UITableViewCell {
    UILabel *loadMoreLabel;
}

@property (nonatomic, strong) UILabel *loadMoreLabel;

@end
