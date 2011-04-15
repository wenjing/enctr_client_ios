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

#define GENERIC_MARGIN			5
#define	PIC_WIDTH				47
#define PIC_HEIGHT              PIC_WIDTH
#define LG_PIC_SIZE             54

#define NAME_TOP_X				(GENERIC_MARGIN+GENERIC_MARGIN+PIC_WIDTH)
#define	NAME_TOP_WIDTH			203

#define LOGO_TOP_X				(NAME_TOP_X+NAME_TOP_WIDTH+GENERIC_MARGIN)
#define LOGO_TOP_Y				(GENERIC_MARGIN)
#define LOGO_WIDTH				16

#define	TIME_TOP_X				(LOGO_TOP_X+LOGO_WIDTH+5)
#define TIME_TOP_Y				(GENERIC_MARGIN)
#define TIME_WIDTH				29

#define CONTENT_TOP_X			NAME_TOP_X
#define CONTENT_TOP_Y			(GENERIC_MARGIN + PIC_WIDTH + GENERIC_MARGIN)
#define CONTENT_WIDTH			244

#define MAIN_FONT_SIZE			12
#define MIN_MAIN_FONT_SIZE		10
#define SECONDARY_FONT_SIZE		10
#define MIN_SECONDARY_FONT_SIZE 8

@interface CirkleEntryView : UIView {
    //data     
    CirkleSummary *circle;
    HJManagedImageV *userImage;
    NSMutableArray *images;
    CGSize      size;
}

@property (nonatomic, retain) HJManagedImageV *userImage;
@property (nonatomic, retain) NSMutableArray *images;

@property (nonatomic, retain) CirkleSummary *circle;
@property (nonatomic) CGSize size;

//use this method to update time string when timer fires off
- (NSString *)updateTimeString;

//use this to set - right after init
- (void)setCircle:(CirkleSummary *)aCircle;

@end
