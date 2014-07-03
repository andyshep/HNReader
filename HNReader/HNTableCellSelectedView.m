//
//  HNTableCellSelectedView.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNTableCellSelectedView.h"

@implementation HNTableCellSelectedView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setBackgroundColor:[HNReaderTheme brightOrangeColor]];
    }
    
    return self;
}

@end
