//
//  HNArtistTools.m
//  HNReader
//
//  Created by Andrew Shepard on 10/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HNArtistTools.h"

@implementation HNArtistTools

void HNDrawGradientInRect(CGContextRef context, CGGradientRef gradient, CGRect rect) {
	CGContextSaveGState(context);
	CGContextClipToRect(context, rect);
	CGPoint start = CGPointMake(rect.origin.x, rect.origin.y);
	CGPoint end = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
	CGContextDrawLinearGradient(context, gradient, start, end, 0);
	CGContextRestoreGState(context);
}

void HNDrawLinearGradientInRect(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(id)startColor, (id)endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, 
                                                        (CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

CGRect HNRectForStroke(CGRect rect) {
    return CGRectMake(rect.origin.x + 0.5, rect.origin.y + 0.5, 
                      rect.size.width - 1, rect.size.height - 1);
}

void HNStrokeRect(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color) {
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

CGGradientRef HNGradientWithColors(UIColor *topColor, UIColor *bottomColor) {
	return HNGradientWithColorsAndLocations(topColor, bottomColor, 0.0f, 1.0f);
}

CGGradientRef HNGradientWithColorsAndLocations(UIColor *topColor, UIColor *bottomColor, CGFloat topLocation, CGFloat bottomLocation) {
	CGFloat locations[] = {
		topLocation,
		bottomLocation
	};
	
	CGColorRef topCGColor = topColor.CGColor;
	CGColorSpaceRef colorSpace = CGColorGetColorSpace(topCGColor);
	NSArray *colors = [[NSArray alloc] initWithObjects:(id)topCGColor, (id)bottomColor.CGColor, nil];
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);
	[colors release];
	
	return gradient;
}

@end
