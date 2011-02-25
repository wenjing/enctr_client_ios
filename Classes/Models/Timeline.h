//
//  Timeline.h
//  Cirkle
//
//  Created by Jun Li on 2/22/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIkit.h>
#import "User.h"
#import "KYMeet.h"

#define IMAGE_PADDING       10
#define H_MARGIN            10
#define INDICATOR_WIDTH     (30 - H_MARGIN)
#define DETAIL_BUTTON_WIDTH (45 - H_MARGIN)

#define IMAGE_WIDTH         48
#define USER_CELL_LEFT      42
#define STAR_BUTTON_WIDTH   32

#define TOP                 (16 + 1)
#define LEFT                (IMAGE_PADDING * 2 + IMAGE_WIDTH)
#define CELL_WIDTH          (320 - LEFT)
#define TIMESTAMP_WIDTH     60
#define TIMESTAMP_LEFT      (LEFT + CELL_WIDTH) - TIMESTAMP_WIDTH

#define USER_CELL_WIDTH     (320 - USER_CELL_LEFT)
#define DETAIL_CELL_WIDTH   (300 - USER_CELL_LEFT)


typedef enum {
	TIMELINE_ENCOUNTER=0,
	TIMELINE_JOIN,
	TIMELINE_TOPIC,
	TIMELINE_COMMENT
} TIMELINE_TYPE ;


@interface Timeline : NSObject
{
	TIMELINE_TYPE	type ;
	uint32_t		tid	 ;
	uint32_t		uid	 ;
	NSString	*img_url ;
	NSString	*topic	 ;
	time_t		 timeAt  ;
	uint32_t	 commentCount	;
	NSMutableArray*	comments	;
	uint32_t		userCount	;
    NSArray*		meetUsers	;
	
	CGRect          textBounds;
    CGRect          bubbleRect;
    CGFloat         cellHeight;
}

@property (nonatomic, assign) NSString*     img_url;
@property (nonatomic, assign) NSString*		topic  ;
@property (nonatomic, assign) uint32_t		tid, commentCount, uid, userCount;
@property (nonatomic, assign) NSArray*		meetUsers ;
@property (nonatomic, retain) NSMutableArray* comments;
@property (nonatomic, assign) time_t timeAt ;
@property (nonatomic, assign) TIMELINE_TYPE type;


@property (nonatomic, assign) CGFloat       cellHeight;
@property (nonatomic, assign) CGRect        textBounds;
@property (nonatomic, assign) CGRect        bubbleRect;


+ (Timeline *) tlWithEncounter:(KYMeet*)mt ;
+ (Timeline *) tlWithTopic:(NSDictionary*)dic ;
+ (Timeline *) tlWithComment:(NSDictionary *)dic;
+ (Timeline *) tlWithJoin :(NSDictionary*)dic withEncounter:(KYMeet*)mt;

- (id) initWithType:(TIMELINE_TYPE)type withId:(uint32_t)aId;
- (id) initWithEncounter:(KYMeet*)meet;

- (void)calcTextBounds:(int)textWidth;

+ (int) getTimelinesFromMt:(KYMeet *)mt withDic:(NSDictionary*)dic Timelines:(NSMutableArray*)tls;

@end
