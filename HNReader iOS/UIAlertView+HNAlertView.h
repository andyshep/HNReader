//
//  UIAlertView+HNAlertView.h
//  HNReader
//
//  Created by Andrew Shepard on 7/6/14.
//
//

#import <UIKit/UIKit.h>

@interface UIAlertView (HNAlertView)

+ (UIAlertView *)hn_alertViewWithError:(NSError *)error;
+ (UIAlertView *)hn_alertViewWithMessage:(NSString *)message;

@end
