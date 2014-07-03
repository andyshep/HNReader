//
//  HNCacheManager.h
//  HNReader
//
//  Created by Andrew Shepard on 2/2/14.
//
//

#import <Foundation/Foundation.h>

@interface HNCacheManager : NSObject

+ (instancetype)sharedManager;

- (NSArray *)cachedEntriesForKey:(NSString *)key;
- (void)cacheEntries:(NSArray *)entries forKey:(NSString *)key;

- (NSDictionary *)cachedCommentsForKey:(NSString *)key;
- (void)cacheComments:(NSDictionary *)comments forKey:(NSString *)key;

@end
