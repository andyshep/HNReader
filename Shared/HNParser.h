//
//  HNParser.h
//  HNReader
//
//  Created by Andrew Shepard on 1/31/14.
//  Copyright 2014 Andrew Shepard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNParser : NSObject

+ (nullable NSDictionary *)parsedEntriesFromResponse:(nullable id)response;
+ (nullable NSDictionary *)parsedCommentsFromResponse:(nullable id)response;

@end
