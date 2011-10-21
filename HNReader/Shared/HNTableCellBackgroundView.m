//
//  HNSelectedTableCellView.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

// based on code and examples from:
// http://www.raywenderlich.com/2033/core-graphics-101-lines-rectangles-and-gradients
// https://github.com/samsoffes/sstoolkit/blob/master/SSToolkit/SSDrawingUtilities.m

#import "HNTableCellBackgroundView.h"


@implementation HNTableCellBackgroundView

@synthesize borderColor;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		gradient = [HNReaderTheme tanGradientColor];
    }
    return self;
}

- (void)dealloc {
    [borderColor release];
	CGGradientRelease(gradient);
    [super dealloc];
}

- (BOOL) isOpaque {
    return NO;
}

- (void)drawRect:(CGRect)rect {    
    // colors used for drawing and stroking
    CGColorRef whiteColor = [UIColor colorWithRed:1.0 green:1.0 
                                             blue:1.0 alpha:1.0].CGColor; 
    CGColorRef lightGrayColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 
                                                 blue:230.0/255.0 alpha:1.0].CGColor;
    CGColorRef separatorColor = [UIColor colorWithRed:208.0/255.0 green:208.0/255.0 
                                                 blue:208.0/255.0 alpha:1.0].CGColor;
    
    // calcuate a rectangle
    CGRect aRect = self.bounds;
    
    CGRect strokeRect = aRect;
    strokeRect.size.height -= 1;
    strokeRect = ASRectForStroke(strokeRect);

    // calculate rect for separator
    CGPoint startPoint = CGPointMake(aRect.origin.x, 
                                     aRect.origin.y + aRect.size.height - 1);
    CGPoint endPoint = CGPointMake(aRect.origin.x + aRect.size.width - 1, 
                                   aRect.origin.y + aRect.size.height - 1);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    ASDrawLinearGradientInRect(context, aRect, whiteColor, lightGrayColor);
    CGContextSetStrokeColorWithColor(context, whiteColor);
    CGContextStrokeRect(context, strokeRect);
    ASStrokeRect(context, startPoint, endPoint, separatorColor);
}

@end
