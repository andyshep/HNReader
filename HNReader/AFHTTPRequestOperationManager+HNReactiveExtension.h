//
//  AFHTTPRequestOperationManager+HNReactiveExtension.h
//  HNReader
//
//  Created by Andrew Shepard on 1/15/14.
//
//

#import "AFHTTPRequestOperationManager.h"

@interface AFHTTPRequestOperationManager (HNReactiveExtension)

- (RACSignal *)signalForRequest:(NSURLRequest *)request;

@end
