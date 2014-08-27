//
//  ImportOperation.h
//  BackgroundFetch
//
//  Created by Shailendra Kr Gangwar on 21/08/14.
//  Copyright (c) 2014 Aksr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Store;


@interface ImportOperation : NSOperation

- (id)initWithStore:(Store *)store fileName:(NSString *)name;
@property (nonatomic) float progress;
@property (nonatomic, copy) void (^progressCallback) (float);

@end