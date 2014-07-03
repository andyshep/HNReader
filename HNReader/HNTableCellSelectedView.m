//
//  HNTableCellSelectedView.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNTableCellSelectedView.h"
#import "UIColor+HNReaderTheme.h"

@implementation HNTableCellSelectedView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setBackgroundColor:[UIColor hn_brightOrangeColor]];
    }
    
    return self;
}

@end
