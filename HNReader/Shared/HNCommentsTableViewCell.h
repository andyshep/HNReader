//
//  HNCommentsTableViewCell.h
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

@interface HNCommentsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentTextLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingSpaceForCommentLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingSpaceForUsernameLabel;
@property (nonatomic, assign) NSInteger padding;

- (void)setCommentText:(NSString *)commentText;

@end
