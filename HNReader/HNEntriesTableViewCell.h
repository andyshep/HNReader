//
//  HNEntriesTableViewCell.h
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNLabel.h"

@interface HNEntriesTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet HNLabel *siteTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *siteDomainLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalPointsLabel;

@end
