//
//  HNCacheManager.m
//  HNReader
//
//  Created by Andrew Shepard on 2/2/14.
//
//

#import "HNCacheManager.h"
#import "HNConstants.h"

@interface HNCacheManager ()

@property (nonatomic, readwrite) NSCache *cache;

- (NSString *)databasePath;
- (void)refreshReaderConnection:(NSNotification *)notification;

@end

@implementation HNCacheManager

+ (instancetype)sharedManager {
    static HNCacheManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init {
    if ((self = [super init])) {
        self.cache = [[NSCache alloc] init];
    }
    
    return self;
}

- (NSArray *)cachedEntriesForKey:(NSString *)key {
    NSArray *entries = [self.cache objectForKey:key];
    return entries;
}

- (void)cacheEntries:(NSArray *)entries forKey:(NSString *)key {
    [self.cache setObject:entries forKey:key];
}

- (id)cachedCommentsForKey:(NSString *)key {
    __block NSDictionary *comments = nil;
//    [self.readerConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
//        comments = [transaction objectForKey:key inCollection:HNCommentsKeyPath];
//    }];
    
    return comments;
}

- (void)cacheComments:(id)comments forKey:(NSString *)key {
//    [self.writerConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
//        NSNumber *metadata = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceReferenceDate]];
//        [transaction setObject:comments forKey:key inCollection:HNCommentsKeyPath withMetadata:metadata];
//    }];
}

#pragma mark - Private
- (NSString *)databasePath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *databasePath = [documentsPath stringByAppendingPathComponent:@"database.sql"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        [[NSFileManager defaultManager] createFileAtPath:databasePath contents:nil attributes:nil];
    }
    
    return databasePath;
}

- (void)refreshReaderConnection:(NSNotification *)notification {
//    [self.readerConnection beginLongLivedReadTransaction];
}

@end
