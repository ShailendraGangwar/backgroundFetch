//
//  ViewController.m
//  BackgroundFetch
//
//  Created by Shailendra on 21/08/14.
//  Copyright (c) 2014 Aksr. All rights reserved.
//

#import "IncidentViewController.h"
#import "Incident.h"
#import "IncidentTableViewCell.h"
#import "NetworkManager.h"
#import "UILabel+boldify.h"
@interface IncidentViewController ()
@property (nonatomic, strong) NSOperationQueue* operationQueue;
@property (nonatomic, strong) IncidentTableViewCell *prototypeCell;
@property (nonatomic) NSUInteger fetchLimit;
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
@end

@implementation IncidentViewController
@synthesize store;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden=YES;
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.store = [[Store alloc] init];
    self.fetchLimit = 20;
    NSFetchedResultsController* fetchedResultsController = [self fetchedResultsController:0 fetchLimit:self.fetchLimit];
    if (fetchedResultsController == nil) {
        NSLog(@"Error");
    }
    [self.tableView registerNib:[UINib nibWithNibName:@"IncidentTableViewCell" bundle:nil] forCellReuseIdentifier:@"IncidentCell"];
    NSString *myString = @"abcdefghijklmnopqrstuvwxyz";
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:[myString length]];
    
    [myString enumerateSubstringsInRange:NSMakeRange(0,[myString length])
                                 options:(NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences)
                              usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                  [reversedString appendString:substring];
                              }];
    NSLog(@"%@",reversedString);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (IBAction)startImport:(id)sender {
    [self sendRequestToServer];
}

- (IBAction)cancel:(id)sender {
    [self.operationQueue cancelAllOperations];
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo =[[mFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"IncidentCell";
    IncidentTableViewCell *cell = (IncidentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (IncidentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    }
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[IncidentTableViewCell class]])
    {
        Incident *info = [mFetchedResultsController objectAtIndexPath:indexPath];
        IncidentTableViewCell *incidentCell = (IncidentTableViewCell *)cell;
        incidentCell.siteNumberLabel.text = [NSString stringWithFormat:@"Site Number: %@",[info valueForKey:@"sitenumber"]];
        [incidentCell.siteNumberLabel boldSubstring: @"Site Number:"];
        incidentCell.incidentNumberLabel.text = [info valueForKey:@"incidentnumber"];
        incidentCell.summaryLabel.text = [NSString stringWithFormat:@"Summary: %@",[info valueForKey:@"summary"]];
        incidentCell.firstLineTeamLabel.text = [NSString stringWithFormat:@"First Line Team: %@",[info valueForKey:@"firstlineteam"]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        NSString *strDate = [dateFormatter stringFromDate:[info valueForKey:@"dateandtimeincidentraised"]];
        incidentCell.dateLabel.text = [NSString stringWithFormat:@"Date: %@",strDate];
        incidentCell.statusLabel.text = [NSString stringWithFormat:@"Status: %@",[info valueForKey:@"status"]];
        incidentCell.typeLabel.text = [NSString stringWithFormat:@"Type: %@",[info valueForKey:@"type"]];
        incidentCell.serviceImpactedLabel.text = [NSString stringWithFormat:@"Service Impacted: %@",[info valueForKey:@"serviceimpacted"]];
        [incidentCell.incidentNumberLabel boldSubstring: @"INC"];
        [incidentCell.firstLineTeamLabel boldSubstring: @"First Line Team:"];
        [incidentCell.dateLabel boldSubstring: @"Date:"];
        [incidentCell.statusLabel boldSubstring: @"Status:"];
        [incidentCell.typeLabel boldSubstring: @"Type:"];
        [incidentCell.serviceImpactedLabel boldSubstring: @"Service Impacted:"];
        [incidentCell.summaryLabel boldSubstring: @"Summary:"];


    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"IncidentCell";
    IncidentTableViewCell *cell = (IncidentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    [cell setNeedsUpdateConstraints];
    float height=  ([cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
    return height;
}


- (NSFetchedResultsController *)fetchedResultsController:(NSInteger)fetchOffset fetchLimit:(NSInteger)fetchLimit
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Incident"];
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"dateandtimeincidentraised"
                                                               ascending:NO];
    NSSortDescriptor *sortByIncidentNumber = [[NSSortDescriptor alloc] initWithKey:@"incidentnumber"
                                                                         ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByDate,sortByIncidentNumber, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setFetchLimit:fetchLimit];
    [fetchRequest setFetchOffset:fetchOffset];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSError* error;
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.store.mainManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    if (![theFetchedResultsController performFetch:&error])
    {
        //Unresolved Error
    }
    mFetchedResultsController = theFetchedResultsController;
    mFetchedResultsController.delegate = self;
    NSLog(@"Count %lu",(unsigned long)mFetchedResultsController.fetchedObjects.count);
    return mFetchedResultsController;
    
    
}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

-(void)sendRequestToServer
{
    NSLog(@"Sending request");
    NetworkManager *network = [[NetworkManager alloc]init];
    network.mNetworkDelegate = self;
    NSMutableDictionary *req = [[NSMutableDictionary alloc]init];
    [req setObject:@"1234" forKey:@"IMEI"];
    [network networkRequest:9001 RequestBody:req isRequestAsynchronous:YES];
}

/**
 * Method name: networkErrorHandling
 * Description: Shows error alert when error occured in network connection
 * Parameters: errorDict,httpResponseCode
 * Returns:
 */
- (void) networkErrorHandling: (NSDictionary*) errorDict responseCode:(int) httpResponseCode
{
    if (httpResponseCode == -1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Ohh!!!" message:@"Your Internet connection seems to be off.Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

/**
 * Method name: processResponse
 * Description: It gets the response from server
 * Parameters: response, requestType
 * Returns:
 */
- (void) processResponse: (id)response RequestType:(NSInteger) requestType
{
    if(requestType == 9001)
    {
        self.progressIndicator.progress = 0;
//        NSString* fileName = [[NSBundle mainBundle] pathForResource:@"Incident" ofType:@"csv"];
//        ImportOperation* operation = [[ImportOperation alloc] initWithStore:self.store fileName:fileName];
        
        NSString* fileName = response;
        ImportOperation* operation = [[ImportOperation alloc] initWithStore:self.store fileName:fileName];
        
        operation.progressCallback = ^(float progress) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 self.progressIndicator.progress = progress;
             }];
        };
        [self.operationQueue addOperation:operation];
    }
}
#pragma UIScroll View Method::
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!self.loading) {
        float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (endScrolling >= scrollView.contentSize.height)
        {
            [self performSelector:@selector(loadDataDelayed) withObject:nil afterDelay:1];
            
        }
    }
}
#pragma UserDefined Method for generating data which are show in Table :::
-(void)loadDataDelayed{
    
    NSFetchedResultsController* fetchedResultsController = [self fetchedResultsController:0 fetchLimit:(self.fetchLimit + 20)];
    if (fetchedResultsController == nil) {
        NSLog(@"Error");
    }
    NSInteger count = fetchedResultsController.fetchedObjects.count;
    NSLog(@"Number of recoreds fetched %ld",(long)count);
    self.fetchLimit = count;
    mFetchedResultsController = fetchedResultsController;
    [self.tableView reloadData];
}

@end
