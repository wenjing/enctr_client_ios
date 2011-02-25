//
//  Timeline.m
//  Cirkle
//
//  Created by Jun Li on 2/22/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "Timeline.h"

@implementation Timeline

@synthesize img_url, topic;
@synthesize tid, uid, userCount, commentCount;
@synthesize meetUsers, comments;
@synthesize timeAt ;
@synthesize type ;

@synthesize textBounds;
@synthesize bubbleRect;
@synthesize cellHeight;


+ (Timeline *) tlWithEncounter:(KYMeet*)mt 
{
	return [[[Timeline alloc] initWithEncounter:mt] autorelease];
}

+ (Timeline *) tlWithTopic:(NSDictionary*)dic 
{
	Timeline *tl = [[[Timeline alloc] initWithType:TIMELINE_TOPIC withId:0] autorelease];
	struct tm created;
    time_t now;
    time(&now);	
	
	tl.tid				 = [[dic objectForKey:@"id"]     longValue];
	tl.uid			     = [[dic objectForKey:@"user_id"] longValue];
	tl.topic			 = [[dic objectForKey:@"content"] retain] ;
	NSString	*tmp = [dic objectForKey:@"chatter_photo_small"] ;
	if ( tmp != (NSString*)[NSNull null] ) tl.img_url = [tmp retain];
	
	strptime([[dic objectForKey:@"updated_at"] UTF8String], "%FT%T%z",  &created) ;
	tl.timeAt = timegm(&created);
	
	// add comments to this topic
	NSArray *cmts = (NSArray *)[dic objectForKey:@"comments"];
	if ( [cmts isKindOfClass:[NSArray class]] && [cmts count]){
		tl.commentCount = [cmts count] ;
		tl.comments = [[NSMutableArray arrayWithCapacity:tl.commentCount] retain] ;
		for( int i = 0 ; i < tl.commentCount ; i ++ ) {
			[tl.comments addObject:[Timeline tlWithComment:(NSDictionary *)[cmts objectAtIndex:i]]];
		}
	}
	return tl ;
}

+ (Timeline *) tlWithComment:(NSDictionary*)dic
{
	Timeline *tl = [[[Timeline alloc] initWithType:TIMELINE_COMMENT withId:0] autorelease];
	struct tm created;
    time_t now;
    time(&now);	
	
	tl.tid				 = [[dic objectForKey:@"id"]      longValue];
	tl.uid			     = [[dic objectForKey:@"user_id"] longValue];
	tl.topic			 = [[dic objectForKey:@"content"] retain] ;
	NSString	*tmp = [dic objectForKey:@"chatter_photo_small"] ;
	if ( tmp != (NSString*)[NSNull null] ) tl.img_url = [tmp retain];
	
	strptime([[dic objectForKey:@"updated_at"] UTF8String], "%FT%T%z",  &created) ;
	tl.timeAt = timegm(&created);
	return tl ;
}

+ (Timeline *) tlWithJoin :(NSDictionary*)dic withEncounter:(KYMeet*)mt
{
	return [Timeline tlWithEncounter:mt];
}

- (id) initWithType:(TIMELINE_TYPE)aType withId:(uint32_t)aId
{
	self = [super init];
    type = aType;
	tid  = aId  ;
 
	img_url = nil;
	topic = nil ;
	
	userCount = 0  ;
	meetUsers = nil;
	commentCount = 0;
	comments = nil ;
	
	return self;
}

- (id) initWithEncounter:(KYMeet*)meet
{
	[self initWithType:TIMELINE_ENCOUNTER withId:meet.meetId];
	userCount = meet.userCount;
	meetUsers = meet.meetUsers;
	timeAt   = meet.timeAt;
	uid		 = meet.user.userId;
	topic	 = [[NSString stringWithFormat:@"%@", meet.description] retain];
	return self;
}

- (void) dealloc 
{
	if ( commentCount ) {
		[comments removeAllObjects];
		[comments release];
	}
	if ( img_url)		[img_url release] ;
	if ( topic )		[topic   release] ;
	
	//NSLog(@"release tl");
	[super dealloc];
}


- (void)calcTextBounds:(int)textWidth
{
    CGRect bounds, result;
    
    if (type == TIMELINE_ENCOUNTER) {
        bounds = CGRectMake(0, TOP, textWidth, 200);
    }
    else { // 
        bounds = CGRectMake(0, 3, textWidth, 200);
    }
    
    static UILabel *label = nil;
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    label.font = [UIFont systemFontOfSize:13];
    label.text = topic;
    result = [label textRectForBounds:bounds limitedToNumberOfLines:20];
    
    textBounds = CGRectMake(bounds.origin.x, bounds.origin.y, textWidth, result.size.height);
    
    if (type == TIMELINE_ENCOUNTER) {
        result.size.height += 18 + 15 + 2;
        if (result.size.height < IMAGE_WIDTH + 1) result.size.height = IMAGE_WIDTH + 1;
    }
    else {
        result.size.height += 22;
    }
    cellHeight = result.size.height;
}


+ (int) getTimelinesFromMt:(KYMeet*)mt withDic:(NSDictionary*)dic Timelines:(NSMutableArray*)tls
{	int cnt ;

	[tls addObject:[[[Timeline alloc] initWithEncounter:mt] autorelease] ];
	NSArray *tps = (NSArray *)[dic objectForKey:@"topics"];
	if ( [tps isKindOfClass:[NSArray class]] ) {
		for ( cnt = 0 ; cnt < [tps count] ; cnt ++ ) {
			NSDictionary *tp = (NSDictionary*)[tps objectAtIndex:cnt];
			if ( ![tp isKindOfClass:[NSDictionary class]] ) continue ;
			[tls addObject:[Timeline tlWithTopic:tp]];
		}
	}
	return cnt+1 ;
}


int sTextWidth[] = {
    CELL_WIDTH,
    USER_CELL_WIDTH,
    DETAIL_CELL_WIDTH,
};

- (void)updateAttribute
{
    int textWidth = sTextWidth[type];
	
    //
    [self calcTextBounds:textWidth];
}

@end
