//
//  HNArtistTools.h
//  HNReader
//
//  Created by Andrew Shepard on 10/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNArtistTools : NSObject

void ASDrawLinearGradientInRect(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor);
void ASStrokeRect(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color);
CGRect ASRectForStroke(CGRect rect);


@end

