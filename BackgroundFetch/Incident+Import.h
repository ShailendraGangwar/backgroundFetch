//
//  Incident+Import.h
//  BackgroundFetch
//
//  Created by Shailendra Kr Gangwar on 21/08/14.
//  Copyright (c) 2014 Aksr. All rights reserved.
//

#import "Incident.h"

@interface Incident (Import)
+ (void)importCSVComponents:(NSArray*)components intoContext:(NSManagedObjectContext*)context;

@end
