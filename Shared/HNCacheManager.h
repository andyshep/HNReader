//
//  HNCacheManager.h
//  HNReader
//
//  Created by Andrew Shepard on 2/2/14.
//
//

#import <Foundation/Foundation.h>

@interface HNCacheManager : NSObject

+ (nonnull instancetype)sharedManager;

- (nullable NSArray *)cachedEntriesForKey:(nonnull NSString *)key;
- (void)cacheEntries:(nonnull NSArray *)entries forKey:(nonnull NSString *)key;

- (nullable NSDictionary *)cachedCommentsForKey:(nonnull NSString *)key;
- (void)cacheComments:(nonnull NSDictionary *)comments forKey:(nonnull NSString *)key;

@end
