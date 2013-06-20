//
//  HNTableCellSelectedView.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNTableCellSelectedView.h"

@interface HNTableCellSelectedView ()

@property (nonatomic, assign) CGGradientRef gradient;

@end

@implementation HNTableCellSelectedView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.gradient = [HNReaderTheme greyGradientColor];
    }
    
    return self;
}

- (void)dealloc {
	CGGradientRelease(_gradient);
}

- (BOOL) isOpaque {
    return NO;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(c, [_borderColor CGColor]);
	HNDrawGradientInRect(c, _gradient, rect);
}

@end
