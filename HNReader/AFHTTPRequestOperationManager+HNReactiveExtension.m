//
//  AFHTTPRequestOperationManager+HNReactiveExtension.m
//  HNReader
//
//  Created by Andrew Shepard on 1/15/14.
//
//

#import "AFHTTPRequestOperationManager+HNReactiveExtension.h"

@implementation AFHTTPRequestOperationManager (HNReactiveExtension)

- (RACSignal *)signalForRequest:(NSURLRequest *)request {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [subscriber sendNext:operation];
            [subscriber sendCompleted];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendError:error];
        }];
        
        [[self operationQueue] addOperation:operation];
        
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }] replayLazily];
}

@end
