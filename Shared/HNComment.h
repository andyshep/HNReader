//
//  HNComment.h
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNComment : NSObject <NSCoding>

@property (nonnull, nonatomic, copy) NSString *username;
@property (nonnull, nonatomic, copy) NSString *timeSinceCreation;
@property (nonnull, nonatomic, copy) NSString *commentString;
@property (nonatomic, assign) NSInteger padding;

@end
