//
//  HNComment.h
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNComment : NSObject <NSCoding> {
    NSString *username, *timeSinceCreation;
    NSString *commentString;
    NSInteger padding;
}

@property (nonatomic, retain) NSString *username, *timeSinceCreation;
@property (nonatomic, retain) NSString *commentString;
@property (assign) NSInteger padding;

@end
