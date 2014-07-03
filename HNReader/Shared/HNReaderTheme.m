//
//  HNReaderTheme.m
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNReaderTheme.h"

@implementation HNReaderTheme

#pragma mark - Colors
+ (UIColor *)brightOrangeColor {
    return [UIColor colorWithRed:1.0f 
                           green:102.0f/255.0f 
                            blue:0.0f 
                           alpha:1.0f];
}

+ (UIColor *)lightTanColor {
    return[UIColor colorWithRed:246.0f/255.0f 
                          green:246.0f/255.0f 
                           blue:239.0f/255.0f 
                          alpha:1.0f];
}

+ (UIColor *)veryDarkGrey {
    return [UIColor colorWithRed:1.0f/255.0f 
                           green:15.0f/255.0f 
                            blue:42.0f/255.0f 
                           alpha:0.0f];
}

@end
