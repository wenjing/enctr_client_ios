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
	
	NSString*		timestamp ;
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
@property (nonatomic, retain) NSString *timestamp ;

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
- (NSString *)timestamp ;
+ (int) getTimelinesFromMt:(KYMeet *)mt withDic:(NSDictionary*)dic Timelines:(NSMutableArray*)tls;

@end
