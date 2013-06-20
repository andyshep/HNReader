//
//  HNEntry.h
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNEntry : NSObject <NSCoding> {
    NSString *title;
    NSString *linkURL, *commentsPageURL, *siteDomainURL;
    NSString *username, *commentsCount;
    NSString *totalPoints;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *linkURL, *commentsPageURL, *siteDomainURL;
@property (nonatomic, strong) NSString *username, *commentsCount;
@property (nonatomic, strong) NSString *totalPoints;

@end
