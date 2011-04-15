//
//  CirkleDetailViewController.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/30/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsQuery.h"
#import "CirkleSummary.h"
#import "CirkleViewController.h"

@interface CirkleDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    CirkleSummary *summary;
    CirkleViewController *upperController;
    NSMutableArray *listDetails;
    NewsQuery *query;
    IBOutlet UITableView *detailTable;    
    NSMutableArray *listMembers;
    IBOutlet UISegmentedControl *segmentedControl;
}
@property (nonatomic, retain) NSMutableArray *listDetails;
@property (nonatomic, retain) NSMutableArray *listMembers;
@property (nonatomic, retain) CirkleSummary *summary;
@property (nonatomic, retain) NewsQuery *query;
@property (nonatomic, retain) CirkleViewController *upperController;
@property (nonatomic, assign) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) UITableView *detailTable;

- (void)restoreAndLoadNews:(BOOL)withUpdate;
- (void)newsDidLoad:(NewsQuery*)sender;

- (IBAction)composeAction:(id)sender;
- (IBAction) addMemberAction:(id)sender;

- (IBAction) segmentedControlIndexChanged;

@end
