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

@interface CirkleDetailViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    CirkleSummary *summary;
    NSMutableArray *listDetails;
    NewsQuery *query;
    CirkleViewController *upperController;
}
@property (nonatomic, retain) NSMutableArray *listDetails;
@property (nonatomic, retain) CirkleSummary *summary;
@property (nonatomic, retain) NewsQuery *query;
@property (nonatomic, retain) CirkleViewController *upperController;

- (void)restoreAndLoadNews:(BOOL)withUpdate;
- (void)newsDidLoad:(NewsQuery*)sender;
- (void)newsDidUpdate:(NewsQuery*)sender;

- (IBAction)composeAction:(id)sender;

@end
