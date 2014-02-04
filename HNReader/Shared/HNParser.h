//
//  HNParser.h
//  HNReader
//
//  Created by Andrew Shepard on 1/31/14.
//  Copyright 2014 Andrew Shepard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNParser : NSObject

+ (NSDictionary *)parsedEntriesFromResponse:(id)response;
+ (NSDictionary *)parsedCommentsFromResponse:(id)response;

@end
