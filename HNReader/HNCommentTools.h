//
//  HNCommentTools.h
//  HNReader
//
//  Created by Andrew Shepard on 11/21/13.
//
//

#import <Foundation/Foundation.h>

@interface HNCommentTools : NSObject

+ (CGRect)frameForString:(NSString *)string withIndentPadding:(NSInteger)padding;

@end
