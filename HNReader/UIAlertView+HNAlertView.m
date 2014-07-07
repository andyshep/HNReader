//
//  UIAlertView+HNAlertView.m
//  HNReader
//
//  Created by Andrew Shepard on 7/6/14.
//
//

#import "UIAlertView+HNAlertView.h"

@implementation UIAlertView (HNAlertView)

+ (UIAlertView *)hn_alertViewWithError:(NSError *)error {
    return [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error alert view title")
                                      message:error.localizedDescription
                                     delegate:nil
                            cancelButtonTitle:NSLocalizedString(@"OK", @"ok button title")
                            otherButtonTitles:nil];
}

@end
