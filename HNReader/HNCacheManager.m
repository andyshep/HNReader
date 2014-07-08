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

@property (nonatomic, strong, readwrite) YapDatabase *database;
@property (nonatomic, strong, readwrite) YapDatabaseConnection *readerConnection;
@property (nonatomic, strong, readwrite) YapDatabaseConnection *writerConnection;

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
        self.database = [[YapDatabase alloc] initWithPath:[self databasePath]];
        self.writerConnection = [self.database newConnection];
        self.readerConnection = [self.database newConnection];
        [self.readerConnection beginLongLivedReadTransaction];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshReaderConnection:) name:YapDatabaseModifiedNotification object:nil];
    }
    
    return self;
}

- (NSArray *)cachedEntriesForKey:(NSString *)key {
    __block BOOL shouldExpireCache = NO;
    __block NSArray *entries = nil;
    [self.readerConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSNumber *metadata = [transaction metadataForKey:key inCollection:HNEntriesKeyPath];
        NSDate *modificationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[metadata doubleValue]];
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:modificationDate];
        if (interval > HNMaxDatabaseCacheInterval) {
            shouldExpireCache = YES;
        } else {
            entries = [transaction objectForKey:key inCollection:HNEntriesKeyPath];
        }
    }];
    
    if (shouldExpireCache) {
        NSLog(@"expiring cache for %@...", key);
        [self.writerConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [transaction removeObjectForKey:key inCollection:HNEntriesKeyPath];
        }];
    }
    
    return entries;
}

- (void)cacheEntries:(NSArray *)entries forKey:(NSString *)key {
    [self.writerConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSNumber *metadata = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceReferenceDate]];
        [transaction setObject:entries forKey:key inCollection:HNEntriesKeyPath withMetadata:metadata];
    }];
}

- (id)cachedCommentsForKey:(NSString *)key {
    __block NSDictionary *comments = nil;
    [self.readerConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        comments = [transaction objectForKey:key inCollection:HNCommentsKeyPath];
    }];
    
    return comments;
}

- (void)cacheComments:(id)comments forKey:(NSString *)key {
    [self.writerConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSNumber *metadata = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceReferenceDate]];
        [transaction setObject:comments forKey:key inCollection:HNCommentsKeyPath withMetadata:metadata];
    }];
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
    [self.readerConnection beginLongLivedReadTransaction];
}

@end
