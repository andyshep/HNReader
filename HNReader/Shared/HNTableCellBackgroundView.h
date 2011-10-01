//
//  JOTableCellBackgroundView.h
//  GrowJo
//
//  Created by Andrew Shepard on 6/12/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "SSDrawingUtilities.h"


@interface HNSelectedTableCellView : UIView {
	UIColor *borderColor;
	CGGradientRef gradient;
}

@property (nonatomic, retain) UIColor *borderColor;

@end
