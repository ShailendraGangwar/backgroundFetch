//
//  ViewController.h
//  BackgroundFetch
//
//  Created by Shailendra on 21/08/14.
//  Copyright (c) 2014 Aksr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImportOperation.h"
#import <CoreData/CoreData.h>
#import "Store.h"
#import "NetworkProcessResponseProtocol.h"
@interface IncidentViewController : UIViewController<NSFetchedResultsControllerDelegate,NetworkProcessResponseProtocol>
{
    NSFetchedResultsController          *mFetchedResultsController;

}
@property (nonatomic, strong) Store* store;
@property (weak, nonatomic) IBOutlet UIProgressView *progressIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)            NSManagedObjectContext     *mManagedObjectContext;
@property (nonatomic) BOOL noMoreResultsAvail;
@property (nonatomic) BOOL loading;
- (IBAction)startImport:(id)sender;
- (IBAction)cancel:(id)sender;

@end
