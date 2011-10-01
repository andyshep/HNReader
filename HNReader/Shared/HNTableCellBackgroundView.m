//
//  JOTableCellBackgroundView.m
//  GrowJo
//
//  Created by Andrew Shepard on 6/12/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNSelectedTableCellView.h"


@implementation HNSelectedTableCellView

@synthesize borderColor;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		gradient = [JOUserInferfaceTools blueishGradientColor];
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
	// Drawing code
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(c, [borderColor CGColor]);
	SSDrawGradientInRect(c, gradient, rect);
   // CGContextStrokeRectWithWidth(c, rect, 1);
}

@end
