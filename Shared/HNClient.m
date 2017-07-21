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

- (NSURLSessionTask *)taskForURLRequest:(NSURLRequest *)request success:(void (^)(NSData *))success error:(void (^)(NSError *))error {
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
