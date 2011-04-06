//
//  CirkleEntryCell.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/27/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CirkleSummary.h"

@class CirkleEntryView;


@interface CirkleEntryCell : UITableViewCell {
    CirkleEntryView *circleView;
}
@property (nonatomic, retain) CirkleEntryView *circleView;

- (void)redisplay;
- (void)setCircle:(CirkleSummary *)aCircle;
- (CGSize)getSize;

@end
