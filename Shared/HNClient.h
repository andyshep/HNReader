//
//  HNClient.h
//  HNReader
//
//  Created by Andrew Shepard on 7/9/14.
//
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface HNClient : NSObject

- (RACSignal *)signalForRequest:(NSURLRequest *)request;
- (NSURLSessionTask *)taskForURLRequest:(NSURLRequest *)request success:(void (^)(id))success error:(void (^)(NSError *))error;

@end
