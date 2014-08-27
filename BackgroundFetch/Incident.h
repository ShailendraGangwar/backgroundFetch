//
//  Incident.h
//  BackgroundFetch
//
//  Created by Shailendra Kr Gangwar on 21/08/14.
//  Copyright (c) 2014 Aksr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Incident : NSManagedObject

@property (nonatomic, retain) NSDate * dateandtimeincidentraised;
@property (nonatomic, retain) NSString * firstlineteam;
@property (nonatomic, retain) NSString * incidentnumber;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * serviceimpacted;
@property (nonatomic, retain) NSString * sitenumber;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * sla;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * type;

@end
