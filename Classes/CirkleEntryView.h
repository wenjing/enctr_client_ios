//
//  CirkleEntryView.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/27/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"
#import "CirkleSummary.h"

@interface CirkleEntryView : UIView {
    //data     
    CirkleSummary *circle;
    HJManagedImageV *userImage;
    NSMutableArray *images;
	UIImage		*circleLogo;
	NSString	*timeString;
    CGSize      size;
}
@property (nonatomic, retain) NSString *nameString;
@property (nonatomic, retain) UIImage *pic;
@property (nonatomic, retain) UIImage *circleLogo;
@property (nonatomic, retain) NSString *timeString;
@property (nonatomic, retain) NSString *contentString;
@property (nonatomic, retain) HJManagedImageV *userImage;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic) NSInteger userId;
@property (nonatomic, retain) CirkleSummary *circle;
@property (nonatomic) CGSize size;

//use this method to update time string when timer fires off
- (void)updateTimeString;

//use this to set - right after init
- (void)setCircle:(CirkleSummary *)aCircle;

@end
