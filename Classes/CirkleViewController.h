//
//  CirkleViewController.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/27/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CirkleQuery.h"

@interface CirkleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *listCircles;
    UITableView *circleTableView;
}
@property (nonatomic, retain) NSMutableArray *listCircles;
@property (nonatomic, retain) IBOutlet UITableView *circleTableView;

- (void)restoreAndLoadCirkles;
- (void)cirklesDidLoad:(CirkleQuery*)sender;

@end
