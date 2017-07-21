//
//  HNEntry.h
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNEntry : NSObject <NSCoding>

@property (nonnull, nonatomic, copy) NSString *title;
@property (nonnull, nonatomic, copy) NSString *linkURL;
@property (nonnull, nonatomic, copy) NSString *commentsPageURL;
@property (nonnull, nonatomic, copy) NSString *siteDomainURL;
@property (nonnull, nonatomic, copy) NSString *username;
@property (nonnull, nonatomic, copy) NSString *commentsCount;
@property (nonnull, nonatomic, copy) NSString *totalPoints;

@end
