//
//  HNClient.m
//  HNReader
//
//  Created by Andrew Shepard on 7/9/14.
//
//

#import "HNClient.h"

@interface HNClient ()

@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfig;

@end

@implementation HNClient

- (instancetype)init {
    if (self = [super init]) {
        self.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return self;
}

- (RACSignal *)signalForRequest:(NSURLRequest *)request {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionTask *task = [self taskForURLRequest:request success:^(id result) {
            [subscriber sendNext:result];
            [subscriber sendCompleted];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        }];
        
        [task resume];
        
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] replayLazily];
}

- (NSURLSessionTask *)taskForURLRequest:(NSURLRequest *)request success:(void (^)(id))success error:(void (^)(NSError *))error {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.sessionConfig];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *err) {
        if (!err) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(data);
                });
            }
        } else {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    error(err);
                });
            }
        }
    }];
    
    return dataTask;
}

@end
