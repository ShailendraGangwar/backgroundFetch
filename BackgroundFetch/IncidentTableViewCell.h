//
//  IncidentTableViewCell.h
//  BackgroundFetch
//
//  Created by Shailendra Kr Gangwar on 21/08/14.
//  Copyright (c) 2014 Aksr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IncidentTableViewCell : UITableViewCell
@property (weak,nonatomic) IBOutlet UILabel *incidentNumberLabel;
@property (weak,nonatomic) IBOutlet UILabel *dateLabel;
@property (weak,nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak,nonatomic) IBOutlet UILabel *siteNumberLabel;
@property (weak,nonatomic) IBOutlet UILabel *firstLineTeamLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceImpactedLabel;

@end
