//
//  CirkleDetailView.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/30/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"
#import "CirkleDetail.h"

#define GENERIC_MARGIN			5
#define	PIC_WIDTH				47
#define PIC_HEIGHT              PIC_WIDTH
#define LG_PIC_SIZE             54
#define CD_MAP_SIZE             100
#define CD_MAP_TOP_X            (GENERIC_MARGIN+GENERIC_MARGIN+PIC_WIDTH)
#define CD_MAP_TOP_Y            (GENERIC_MARGIN+GENERIC_MARGIN+PIC_WIDTH)
#define CD_ADDR_WIDTH           140
#define CD_ADDR_HEIGHT          CD_MAP_SIZE
#define CD_ADDR_TOP_X           (4*GENERIC_MARGIN+PIC_WIDTH+CD_MAP_SIZE)
#define CD_PHOTO_SIZE           245

#define NAME_TOP_X				(GENERIC_MARGIN+GENERIC_MARGIN+PIC_WIDTH)
#define	NAME_TOP_WIDTH			200

#define LOGO_TOP_X				(NAME_TOP_X+NAME_TOP_WIDTH+GENERIC_MARGIN)
#define LOGO_TOP_Y				(GENERIC_MARGIN+12)
#define LOGO_WIDTH				24

#define	TIME_TOP_X				(LOGO_TOP_X+5)
#define TIME_TOP_Y				(GENERIC_MARGIN)
#define TIME_WIDTH				48

#define CD_NAME_TOP_X			NAME_TOP_X
#define CD_NAME_TOP_Y			(GENERIC_MARGIN + PIC_WIDTH + GENERIC_MARGIN + CD_MAP_SIZE + GENERIC_MARGIN)
#define CD_CONTENT_WIDTH		253

#define CD_COMBUT_WIDTH         60
#define CD_COMBUT_HEIGHT        20

#define MAIN_FONT_SIZE			12
#define MIN_MAIN_FONT_SIZE		10
#define SECONDARY_FONT_SIZE		10
#define MIN_SECONDARY_FONT_SIZE 8

@interface CirkleDetailView : UIView {
    //data     
    CirkleDetail *circleDetail;
    HJManagedImageV *userImage;
    NSMutableArray *images;
    CGSize      size_names;
    NSInteger   rowsOfImages;
//    CGSize      size_comments;
    UIButton    *commentButton;
}

@property (nonatomic, retain) HJManagedImageV *userImage;
@property (nonatomic, retain) NSMutableArray *images;

@property (nonatomic, retain) CirkleDetail *circleDetail;
@property (nonatomic) CGSize size_names;
@property (nonatomic) NSInteger rowsOfImages;

@property (nonatomic, retain) UIButton *commentButton;

//use this method to update time string when timer fires off
- (NSString *)updateTimeString;

//use this to set - right after init
- (void)setCircleDetail:(CirkleDetail *)aCircleDetail;
- (void) encounterDetailSet;
- (void) topicDetailSet;

//after set is completed, use this tor return size
- (NSInteger)getSize;

- (void)addComment:(UIButton *)sender;

@end
