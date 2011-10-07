//
//  HNComment.h
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNComment : NSObject {
    NSString *username;
    NSString *commentString;
    NSInteger padding;
    CGFloat height;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *commentString;
@property (assign) NSInteger padding;
@property (assign) CGFloat height;

@end
