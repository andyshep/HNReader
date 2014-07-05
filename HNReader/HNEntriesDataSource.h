//
//  HNEntriesDataSource.h
//  HNReader
//
//  Created by Andrew Shepard on 7/5/14.
//
//

#import <Foundation/Foundation.h>

@class HNEntriesModel;

@interface HNEntriesDataSource : NSObject <UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView *)tableView;

@property (nonatomic, weak, readonly) NSArray *entries;
@property (nonatomic, weak, readonly) NSError *error;

- (void)loadEntriesForIndex:(NSUInteger)index;
- (void)reloadEntriesForIndex:(NSUInteger)index;

@end
