//
//  Incident+Import.m
//  BackgroundFetch
//
//  Created by Shailendra Kr Gangwar on 21/08/14.
//  Copyright (c) 2014 Aksr. All rights reserved.
//

#import "Incident+Import.h"

@implementation Incident (Import)
+ (instancetype)findOrCreateWithIdentifier:(id)identifier inContext:(NSManagedObjectContext*)context {
    NSString* entityName = NSStringFromClass(self);
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"incidentnumber = %@", identifier];
    fetchRequest.fetchLimit = 1;
    id object = [[context executeFetchRequest:fetchRequest error:NULL] lastObject];
    if(object == nil) {
        object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }
    return object;
}

+ (void)importCSVComponents:(NSArray*)components intoContext:(NSManagedObjectContext*)context
{
//    if (components.count < 9) {
//        return;
//    }
    assert(components.count == 9);
    NSString* identifier = components[2];
    NSString* sitenumber = components[0];
    NSString* summary = components[5];
    NSString* firstlineteam = components[6];
    NSString* dateString = components[4];
    NSString* type = components[8];
    NSString* priority = components[7];
    NSString* status = components[3];
    NSString* serviceimpacted = components[1];
    
    Incident* incident = [self findOrCreateWithIdentifier:identifier inContext:context];

    incident.incidentnumber = identifier;
    incident.sitenumber = sitenumber;
    incident.summary = summary;
    incident.firstlineteam = firstlineteam;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    NSDate *date = [dateFormatter dateFromString:dateString];
    incident.dateandtimeincidentraised = date;
    incident.status = status;
    //incident.priority = priority;
    incident.type = type;
    incident.serviceimpacted = serviceimpacted;


    
    

}

@end
