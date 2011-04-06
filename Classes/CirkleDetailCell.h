//
//  CirkleDetailCell.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/30/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CirkleDetail.h"
#import "CirkleDetailView.h"

@interface CirkleDetailCell : UITableViewCell {
    CirkleDetailView *circleDetailView;
}
@property (nonatomic, retain) CirkleDetailView *circleDetailView;

- (void)redisplay;
- (void)setCircleDetail:(CirkleDetail *)aCircleDetail;
- (NSInteger)getSize;

@end
