//
//  HNCommentsTableViewCell.h
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNLabel.h"

@interface HNCommentsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet HNLabel *usernameLabel;
@property (nonatomic, weak) IBOutlet HNLabel *timeLabel;
@property (nonatomic, weak) IBOutlet HNLabel *commentTextLabel;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingSpaceForCommentLabel;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingSpaceForUsernameLabel;
@property (nonatomic, assign) NSInteger padding;

- (void)setCommentText:(NSString *)commentText;

@end
