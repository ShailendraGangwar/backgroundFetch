//
//  NSString+ParseCSV.m
//  BackgroundFetch
//
//  Created by Shailendra Kr Gangwar on 21/08/14.
//  Copyright (c) 2014 Aksr. All rights reserved.
//

#import "NSString+ParseCSV.h"

@implementation NSString (ParseCSV)
- (NSArray*)csvComponents
{
    NSMutableArray* components = [NSMutableArray array];
    NSScanner* scanner = [NSScanner scannerWithString:self];
    NSString* quote = @"\"";
    NSString* separator = @"$";
    NSString* result;
    while(![scanner isAtEnd]) {
        if([scanner scanString:quote intoString:NULL]) {
            [scanner scanUpToString:quote intoString:&result];
            [scanner scanString:quote intoString:NULL];
        } else {
            [scanner scanUpToString:separator intoString:&result];
        }
        [scanner scanString:separator intoString:NULL];
        [components addObject:result];
    }
    return components;
}

@end
