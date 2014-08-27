//
//  UILabel+boldify.m
//  BackgroundFetch
//
//  Created by Shailendra Kr Gangwar on 23/08/14.
//  Copyright (c) 2014 Aksr. All rights reserved.
//

#import "UILabel+boldify.h"

@implementation UILabel (boldify)
- (void) boldRange: (NSRange) range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.text] ;
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.font.pointSize]} range:range];
    
    self.attributedText = attributedText;
}

- (void) boldSubstring: (NSString*) substring {
    NSRange range = [self.text rangeOfString:substring];
    [self boldRange:range];
}
@end
