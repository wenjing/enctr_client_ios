//
//  CirkleViewController.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/27/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CirkleQuery.h"
#import "EGORefreshTableHeaderView.h"

@interface CirkleViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *listCircles;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property (nonatomic, retain) NSMutableArray *listCircles;

- (void)restoreAndLoadCirkles:(BOOL)withUpdate;
- (void)cirklesDidLoad:(CirkleQuery*)sender;

@end
