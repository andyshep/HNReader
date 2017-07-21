//
//  HNClient.h
//  HNReader
//
//  Created by Andrew Shepard on 7/9/14.
//
//

#import <Foundation/Foundation.h>

@interface HNClient : NSObject

- (NSURLSessionTask *)taskForURLRequest:(NSURLRequest *)request success:(void (^)(id))success error:(void (^)(NSError *))error;

@end
