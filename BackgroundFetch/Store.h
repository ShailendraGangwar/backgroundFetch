//
//  Store.h
//  BackgroundFetch
//
//  Created by Apple on 21/08/14.
//  Copyright (c) 2014 Aksr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface Store : NSObject

@property (nonatomic,strong,readonly) NSManagedObjectContext* mainManagedObjectContext;

- (void)saveContext;
- (NSManagedObjectContext*)newPrivateContext;
@end
