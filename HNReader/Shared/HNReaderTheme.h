//
//  HNReaderTheme.h
//  HNReader
//
//  Created by Andrew Shepard on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SSDrawingUtilities.h"

@interface HNReaderTheme : NSObject

+ (UIFont *)tenPointlabelFont;
+ (UIFont *)twelvePointlabelFont;
+ (UIFont *)fourteenPointlabelFont;

+ (UIColor *)brightOrangeColor;
+ (UIColor *)lightTanColor;
+ (UIColor *)veryDarkGrey;

+ (CGGradientRef)tanGradientColor;
+ (CGGradientRef)blueishGradientColor;

@end
