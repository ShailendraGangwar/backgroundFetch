//
//  UILabel+boldify.h
//  BackgroundFetch
//
//  Created by Shailendra Kr Gangwar on 23/08/14.
//  Copyright (c) 2014 Aksr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (boldify)
- (void) boldSubstring: (NSString*) substring;
- (void) boldRange: (NSRange) range;
@end
