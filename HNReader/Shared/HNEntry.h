//
//  HNEntry.h
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface HNEntry : MTLModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *linkURL;
@property (nonatomic, copy) NSString *commentsPageURL;
@property (nonatomic, copy) NSString *siteDomainURL;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *commentsCount;
@property (nonatomic, copy) NSString *totalPoints;

@end
