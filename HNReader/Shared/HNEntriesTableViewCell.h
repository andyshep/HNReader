//
//  HNEntriesTableViewCell.h
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderTheme.h"
#import "HNTableCellBackgroundView.h"
#import "HNTableCellSelectedView.h"

@interface HNEntriesTableViewCell : UITableViewCell {
    UILabel *siteTitleLabel, *siteDomainLabel, *totalPointsLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *siteTitleLabel, *siteDomainLabel, *totalPointsLabel;

@end
