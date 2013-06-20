//
//  HNComment.h
//  HNReader
//
//  Created by Andrew Shepard on 10/6/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface HNComment : MTLModel

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *timeSinceCreation;
@property (nonatomic, copy) NSString *commentString;
@property (nonatomic, assign) NSInteger padding;

@end
