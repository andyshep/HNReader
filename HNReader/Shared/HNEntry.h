//
//  HNEntry.h
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNEntry : NSObject {
    NSString *title;
    NSString *linkURL, *commentsPageURL, *siteDomainURL;
    NSString *username, *commentsCount;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *linkURL, *commentsPageURL, *siteDomainURL;
@property (nonatomic, retain) NSString *username, *commentsCount;

@end
