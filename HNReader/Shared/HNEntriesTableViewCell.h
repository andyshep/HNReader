//
//  HNEntriesTableViewCell.h
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

@interface HNEntriesTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *siteTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *siteDomainLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalPointsLabel;

@end
