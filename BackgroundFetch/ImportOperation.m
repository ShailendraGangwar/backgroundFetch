//
//  ImportOperation.m
//  BackgroundFetch
//
//  Created by Shailendra Kr Gangwar on 21/08/14.
//  Copyright (c) 2014 Aksr. All rights reserved.
//

#import "ImportOperation.h"
#import "Store.h"
#import "Incident.h"
#import "Incident+Import.h"
#import "NSString+ParseCSV.h"



static const int ImportBatchSize = 250;

@interface ImportOperation ()
@property (nonatomic, copy) NSString* fileName;
@property (nonatomic, strong) Store* store;
@property (nonatomic, strong) NSManagedObjectContext* context;
@end

@implementation ImportOperation
    

- (id)initWithStore:(Store*)store fileName:(NSString*)name
{
    self = [super init];
    if(self) {
        self.store = store;
        self.fileName = name;
    }
    return self;
}


- (void)main
{
    self.context = [self.store newPrivateContext];
    self.context.undoManager = nil;
    
    [self.context performBlockAndWait:^
     {
         [self import];
     }];
}

- (void)import
{
    //NSString* fileContents = [NSString stringWithContentsOfFile:self.fileName encoding:NSUTF8StringEncoding error:NULL];
    NSString* fileContents = self.fileName;
    NSArray* lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger count = lines.count;
    NSInteger progressGranularity = count/100;
    __block NSInteger idx = -1;
    [fileContents enumerateLinesUsingBlock:^(NSString* line, BOOL* shouldStop)
     {
         idx++;
         if(self.isCancelled) {
             *shouldStop = YES;
             return;
         }
         
         NSArray* components = [line csvComponents];
         
         if (components.count < 9) {
             NSLog(@"couldn't parse: %@", components);
             //return;
         }
         assert(components.count == 9);
         
         [Incident importCSVComponents:components intoContext:self.context];
         
         if (idx % progressGranularity == 0) {
             self.progressCallback(idx / (float) count);
         }
         if (idx % ImportBatchSize == 0) {
             [self.context save:NULL];
         }
     }];
    self.progressCallback(1);
    [self.context save:NULL];
}

@end