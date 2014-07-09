//
//  HNCommentsDataSource.h
//  HNReader
//
//  Created by Andrew Shepard on 7/6/14.
//
//

#import <Foundation/Foundation.h>

@class HNEntry;
@class HNCommentsTableViewCell;
@class HNEntriesTableViewCell;

@interface HNCommentsDataSource : NSObject <UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView *)tableView entry:(HNEntry *)entry;

@property (nonatomic, weak, readonly) NSDictionary *comments;
@property (nonatomic, weak, readonly) NSError *error;

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
- (void)reloadComments;

@end
