//
//  HNTableCellSelectedView.h
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNReaderTheme.h"


@interface HNTableCellSelectedView : UIView {
	UIColor *borderColor;
	CGGradientRef gradient;
}

@property (nonatomic, strong) UIColor *borderColor;

@end
