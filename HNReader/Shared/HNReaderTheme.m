//
//  HNReaderTheme.m
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNReaderTheme.h"

@implementation HNReaderTheme

#pragma mark -
#pragma mark Fonts for UI elements

+ (UIFont *)twelvePointlabelFont {
	return [UIFont fontWithName:@"Verdana" size:12];
}

+ (UIFont *)fourteenPointlabelFont {
	return [UIFont fontWithName:@"Verdana" size:14];
}

#pragma mark -
#pragma mark Colors for UI elements

+ (UIColor *)brightOrangeColor {
    return [UIColor colorWithRed:1.0 
                           green:102.0/255.0 
                            blue:0.0 
                           alpha:1.0];
}

+ (UIColor *)lightTanColor {
    return[UIColor colorWithRed:246.0/255.0 
                          green:246.0/255.0 
                           blue:239.0/255.0 
                          alpha:1.0];
}

@end
