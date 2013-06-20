//
//  HNReaderTheme.m
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNReaderTheme.h"

@implementation HNReaderTheme

#pragma mark -
#pragma mark Fonts for UI elements

+ (UIFont *)tenPointlabelFont {
	return [UIFont fontWithName:@"Verdana" size:10];
}

+ (UIFont *)twelvePointlabelFont {
	return [UIFont fontWithName:@"Verdana" size:12];
}

+ (UIFont *)fourteenPointlabelFont {
	return [UIFont fontWithName:@"Verdana" size:14];
}

#pragma mark -
#pragma mark Colors for UI elements

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

+ (CGGradientRef)blueishGradientColor {
	UIColor *topColor = [UIColor colorWithRed:(122.0f/255.f) 
                                        green:(202.0f/255.0f) 
                                         blue:(255.0f/255.0f) 
                                        alpha:(255.0f/255.0f)];
	
	UIColor *bottomColor = [UIColor colorWithRed:(0.0f/255.f) 
										   green:(153.0f/255.0f) 
											blue:(255.0f/255.0f) 
										   alpha:(255.0f/255.0f)];
	
	return HNGradientWithColors(topColor, bottomColor);
}

+ (CGGradientRef)tanGradientColor {
	UIColor *topColor = [UIColor colorWithRed:242.0f/255.0f 
                                         green:242.0f/255.0f 
                                          blue:239.0f/255.0f 
                                         alpha:1.0f];
	
	UIColor *bottomColor = [UIColor colorWithRed:(252.0f/255.f) 
										   green:(252.0f/255.0f) 
											blue:(251.0f/255.0f) 
										   alpha:(1.0f)];
	
	return HNGradientWithColors(bottomColor, topColor);
}

+ (CGGradientRef)greyGradientColor {
	UIColor *topColor = [UIColor colorWithRed:152.0f/255.0f 
                                        green:169.0f/255.0f 
                                         blue:179.0f/255.0f 
                                        alpha:1.0f];
	
	UIColor *bottomColor = [UIColor colorWithRed:(124.0f/255.f) 
										   green:(133.0f/255.0f) 
											blue:(138.0f/255.0f) 
										   alpha:(1.0f)];
	
	return HNGradientWithColors(topColor, bottomColor);
}

@end
