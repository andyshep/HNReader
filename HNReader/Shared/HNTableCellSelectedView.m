//
//  HNTableCellSelectedView.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNTableCellSelectedView.h"


@implementation HNTableCellSelectedView

@synthesize borderColor;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		gradient = [HNReaderTheme greyGradientColor];
    }
    return self;
}

- (void)dealloc {
	CGGradientRelease(gradient);
}

- (BOOL) isOpaque {
    return NO;
}

- (void)drawRect:(CGRect)rect {
	// Drawing code
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(c, [borderColor CGColor]);
	HNDrawGradientInRect(c, gradient, rect);
   // CGContextStrokeRectWithWidth(c, rect, 1);
}

@end
