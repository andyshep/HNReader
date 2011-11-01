//
//  HNArtistTools.h
//  HNReader
//
//  Created by Andrew Shepard on 10/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

// based on code and examples from:
// http://www.raywenderlich.com/2033/core-graphics-101-lines-rectangles-and-gradients
// https://github.com/samsoffes/sstoolkit/blob/master/SSToolkit/SSDrawingUtilities.m

#import <Foundation/Foundation.h>

@interface HNArtistTools : NSObject

// FIXME: don't need both of these
void HNDrawGradientInRect(CGContextRef context, CGGradientRef gradient, CGRect rect);
void HNDrawLinearGradientInRect(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor);

void HNStrokeRect(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color);

CGRect HNRectForStroke(CGRect rect);
CGGradientRef HNGradientWithColors(UIColor *topColor, UIColor *bottomColor);
CGGradientRef HNGradientWithColorsAndLocations(UIColor *topColor, UIColor *bottomColor, CGFloat topLocation, CGFloat bottomLocation);

@end

