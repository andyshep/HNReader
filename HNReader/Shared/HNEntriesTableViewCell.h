//
//  HNEntriesTableViewCell.h
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderTheme.h"

@interface HNEntriesTableViewCell : UITableViewCell {
    UILabel *siteTitleLabel, *siteDomainLabel, *commentsCountLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *siteTitleLabel, *siteDomainLabel, *commentsCountLabel;

@end
