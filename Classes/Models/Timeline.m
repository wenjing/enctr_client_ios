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
@synthesize tid, uid, userCount, commentCount, timestamp;
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
	NSString	*tmp = [dic objectForKey:@"chatter_photo"] ;
	
	if ( tmp != (NSString*)[NSNull null] && [tmp length] > 2 ) 
		 tl.img_url = [tmp retain];
	
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
	NSString	*tmp = [dic objectForKey:@"chatter_photo"] ;
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

#define MAPURL_STRING @"http://maps.google.com/maps/api/staticmap?zoom=11&size=245x123&maptype=roadmap&format=png32&markers=color:green|size:small"



- (id) initWithEncounter:(KYMeet*)meet
{
	[self initWithType:TIMELINE_ENCOUNTER withId:meet.meetId];
	userCount = meet.userCount;
	meetUsers = meet.meetUsers;
	timeAt   = meet.timeAt;
	uid		 = meet.user.userId;
	topic	 = [[NSString stringWithFormat:@"%@", meet.place] retain];
	
	if ( meet.latitude != 0.0 && meet.longitude != 0.0 ) 
		img_url = [[NSString stringWithFormat:@"%@|%lf,%lf&sensor=false",MAPURL_STRING, meet.latitude, meet.longitude] retain];
	
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
	[timestamp release];
	[super dealloc];
}

+ (int) getTimelinesFromMt:(KYMeet*)mt withDic:(NSDictionary*)dic Timelines:(NSMutableArray*)tls
{	int cnt = 0;

	[tls addObject:[[[Timeline alloc] initWithEncounter:mt] autorelease] ];
	NSArray *tps = (NSArray *)[dic objectForKey:@"topics"];
	if ( [tps isKindOfClass:[NSArray class]] ) {
		for ( cnt = 0 ; cnt < [tps count] ; cnt ++ ) {
			NSDictionary *tp = (NSDictionary*)[tps objectAtIndex:cnt];
			if ( ![tp isKindOfClass:[NSDictionary class]] ) continue ;
			if ( [tp objectForKey:@"user_id"] == (NSString*)[NSNull null] ) continue ;
			[tls addObject:[Timeline tlWithTopic:tp]];
		}
	}
	return cnt+1 ;
}

- (NSString*)timestamp
{
    // Calculate distance time string
    //
    time_t now;
    time(&now);
	
    int distance = (int)difftime(now, timeAt);
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        self.timestamp = [NSString stringWithFormat:@"%ds", distance];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        self.timestamp = [NSString stringWithFormat:@"%dm",distance];
    }  
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        self.timestamp = [NSString stringWithFormat:@"%dh",distance];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        self.timestamp = [NSString stringWithFormat:@"%dd",distance];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        self.timestamp = [NSString stringWithFormat:@"%dw",distance];
    }
    else {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeAt];        
        self.timestamp = [dateFormatter stringFromDate:date];
    }
    return timestamp;
}

@end
