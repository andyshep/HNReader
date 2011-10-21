//
//  HNSelectedTableCellView.h
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//


// #import "SSDrawingUtilities.h"
#import "HNReaderTheme.h"
#import "HNArtistTools.h"

@interface HNTableCellBackgroundView : UIView {
	UIColor *borderColor;
	CGGradientRef gradient;
}

@property (nonatomic, retain) UIColor *borderColor;

@end
