//
//  NSString+HNCommentTools.m
//  HNReader
//
//  Created by Andrew Shepard on 7/3/14.
//
//

#import "NSString+HNCommentTools.h"

#define COMMENT_CELL_MARGIN 10.0f

@implementation NSString (HNCommentTools)

- (CGRect)hn_frameForStringWithIndentPadding:(NSInteger)padding {
    // knock the intentation padding down by a factor of 3
    // then adjust for cell margin and make sure the padding is even.
    // otherwise the comment text is antialiased
    padding = COMMENT_CELL_MARGIN + (padding * 0.3f);
    if (padding % 2 != 0) {
        padding += 1;
    }
    
    CGFloat width = 310.0f;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(orientation)) {
        // width = CGRectGetHeight(self.view.frame) - 30.0f;
        width = 560.0f;
    }
    
    int adjustedWidth = width - padding;
    if (adjustedWidth % 2 != 0) {
        adjustedWidth += 1.0f;
    }
    
    CGSize constraint = CGSizeMake(floorf(adjustedWidth) - COMMENT_CELL_MARGIN, 20000.0f);
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]};
    
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
    CGSize size = [self boundingRectWithSize:constraint options:options attributes:attributes context:nil].size;
    return CGRectMake(padding, 0.0f, adjustedWidth, size.height);
}

@end
