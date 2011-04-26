//
//  CirkleDetail.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/30/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleDetail.h"
#import <CoreText/CoreText.h>

@implementation CirkleDetail
@synthesize cId;
@synthesize nameString;
@synthesize addrString;
@synthesize avatarUrl;
@synthesize timeAt;
@synthesize score;
@synthesize type;
@synthesize user;
@synthesize imageUrl;
@synthesize nameList;
@synthesize contentString;
@synthesize latitude;
@synthesize longitude;
@synthesize size;

- (CTFramesetterRef) getFramesetter
{
    return framesetter;
}

// Why isn't this in template?
- (void)dealloc
{
    [nameString release];
    [addrString release];
    [avatarUrl release];
    [user release];
    [imageUrl removeAllObjects];
    [imageUrl release];
    [nameList release];
    [contentString release];
    if (framesetter!=nil)
        CFRelease(framesetter);
    [super dealloc];
}

- (void)parseEncounter:(NSDictionary*)dic {
    //set type
    type = CD_TYPE_ENCOUNETR;
    
    //get name
    nameString = [[dic objectForKey:@"name"] retain];
    
    //NSLog(@"name %@",nameString);
    
    //get address
    NSString *theAddrString = [dic objectForKey:@"location"]; //no retain
    //
    //NSLog(@"addr %@",theAddrString);
    
    //get time of original encounter - this time is not refreshed
    struct tm   timeStruct;
    time_t encounterTime;
    
    NSString* stringOftime = [dic objectForKey:@"time"] ; //no retain
    if ( stringOftime ) {
        strptime([stringOftime UTF8String], "%FT%T%z",  &timeStruct) ;
        encounterTime   = timegm(&timeStruct);
    }
    
    //construct date and time string
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMMyyyy" options:0
                                                                  locale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:formatString];
        
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:encounterTime];        
    NSString *dateTimeString = [dateFormatter stringFromDate:date];
    
    //construct the circle address and time description
    addrString = [[NSString alloc] initWithFormat:@"Near:\n%@\n\n%@", theAddrString, dateTimeString];
    
    //init imageUrl
    imageUrl = [[NSMutableArray alloc] init];
    
    //get map image url
    longitude        = [[dic objectForKey:@"lng"]    floatValue] ;
    latitude         = [[dic objectForKey:@"lat"]    floatValue] ;
    //to-do: cleanup
    NSString *headmapurl = @"http://maps.google.com/maps/api/staticmap?zoom=11&size=100x100&maptype=roadmap&format=png32&markers=color:green|size:small";
    
    NSString *mapurl = [NSString stringWithFormat:@"%@|%lf,%lf&sensor=false",headmapurl,latitude,longitude];
    
    mapurl = [mapurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"Map Url at model %@", mapurl);
    [imageUrl addObject:[NSString stringWithString:mapurl]];
    
    //get people image url
    nameList = [[NSMutableString alloc] init];
    
    NSArray *userList = (NSArray *)[dic objectForKey:@"users"];
    if ([userList isKindOfClass:[NSArray class]]) {
        for (int i=0; i<[userList count]; i++) {
            NSArray *aUser = (NSArray *)[userList objectAtIndex:i];
            if (![aUser isKindOfClass:[NSArray class]]) {
                NSLog(@"Bad format from CirkleDetail dictionary users array");
                continue;
            }
            //first object is the user
            User *userObject = [aUser objectAtIndex:0];
            
            if (userObject!=nil) {
                //NSLog(@"Read a user %@", userObject.name);
                [imageUrl addObject:[userObject.profileImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [nameList appendFormat:@"%@, ", userObject.name];
                
            }
        }
    }
    
    //get chatter string
    NSArray *chatters = (NSArray *)[dic objectForKey:@"chatters"];
    
    if (([chatters isKindOfClass:[NSArray class]]) && ([chatters count] > 0)) {
        //reverse the order
        for (int i = [chatters count] - 1; i>=0; i--) {
            //get content and user
            NSDictionary *aChatter = [chatters objectAtIndex:i];
            if (![aChatter isKindOfClass:[NSDictionary class]]) {
                NSLog(@"Bad format from CirkleDetail chatters array");
                continue;
            }
            //content
            NSString *aContent = [aChatter objectForKey:@"content"];
            //user
            NSArray *aUser = [aChatter objectForKey:@"user"];
            if (![aUser isKindOfClass:[NSArray class]]) {
                NSLog(@"Bad format from CirkleDetail chatter user");
                continue;
            }
            //first object is the user
            User *userObject = [aUser objectAtIndex:0];
            if (userObject) {
                //construct the string
                if (contentString==nil) {
                    contentString = [[NSMutableAttributedString alloc] init];
                }
                //[contentString appendFormat:@"%@:\n    %@\n", userObject.name, aContent];
                //NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:userObject.name, @"name", aContent, @"comment", nil];
                //[contentString addObject:dict];
                //[dict release];
                CTFontRef ctNameFont = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 
                                                            12, /*nameFont.pointSize, */
                                                            NULL);
                
                CTFontRef ctMainFont = CTFontCreateWithName(CFSTR("Helvetica"), 
                                                            12, /*mainFont.pointSize, */
                                                            NULL);
                
                NSString *fullcomment = [NSString stringWithFormat:@"%@: %@\n",userObject.name,aContent];
                
                NSMutableAttributedString *oneComment = [[NSMutableAttributedString alloc] initWithString:fullcomment];
                
                [oneComment addAttribute:(NSString*)kCTFontAttributeName value:(id)ctNameFont range:NSMakeRange(0, [userObject.name length])];
                
                [oneComment addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor blackColor].CGColor range:NSMakeRange(0, [userObject.name length])];
                
                [oneComment addAttribute:(NSString*)kCTFontAttributeName value:(id)ctMainFont range:NSMakeRange([userObject.name length], [oneComment length]-[userObject.name length])];
                
                [contentString appendAttributedString:oneComment];
                
            }
            //if anything goes wrong, do nothing in this for loop
        }
    } //end of get chatter string
    
    //NSLog(@"comments %@", contentString);
    return;
}

- (void) parseTopic:(NSDictionary*)dic {
    //set type
    type = CD_TYPE_TOPIC;
    
    //get name of the user
    NSArray *userArray = (NSArray *)[dic objectForKey:@"user"];
    if (![userArray isKindOfClass:[NSArray class]]) {
        NSLog(@"Bad format from CirkleDetail dictionary users array");
        return;
    }
    
    //to-do: double check if we really need this user pointer saved
    user = (User *)[[userArray objectAtIndex:0] retain];
    if (user != nil) {
        nameString = [[NSString alloc] initWithString:user.name];
        //no need for avatar - the view gets it directly from circleDetail object
        //avatarUrl = [NSURL URLWithString:[user.profileImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else {
        NSLog(@"Error reading user from topic dictionary");
    }
    
    //NSLog(@"name %@",nameString);
    // these return nil if non there
    longitude        = [[dic objectForKey:@"lng"]    floatValue] ;
    latitude         = [[dic objectForKey:@"lat"]    floatValue] ;

    //init imageUrl
    imageUrl = [[NSMutableArray alloc] init];
    
    NSString *photoUrl = [[dic objectForKey:@"chatter_photo"] retain];
    if ((photoUrl) && [photoUrl isKindOfClass:[NSString class]]) {
        [imageUrl addObject:[photoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //first the content string at photo level
    NSString *tContent = [dic objectForKey:@"content"]; //no retain
    if ((tContent) && [tContent isKindOfClass:[NSString class]]) {
        if (contentString==nil) {
            contentString = [[NSMutableAttributedString alloc] init];
        }
        
        //[contentString appendFormat:@"%@:\n    %@\n", user.name, tContent];
        //NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:user.name, @"name", tContent, @"comment", nil];
        //[contentString addObject:dict];
        //[dict release];
        CTFontRef ctNameFont = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 
                                                    12, /*nameFont.pointSize, */
                                                    NULL);
        
        CTFontRef ctMainFont = CTFontCreateWithName(CFSTR("Helvetica"), 
                                                    12, /*mainFont.pointSize, */
                                                    NULL);
        
        NSString *fullcomment = [NSString stringWithFormat:@"%@: %@\n",user.name,tContent];
        
        NSMutableAttributedString *oneComment = [[NSMutableAttributedString alloc] initWithString:fullcomment];
        
        [oneComment addAttribute:(NSString*)kCTFontAttributeName value:(id)ctNameFont range:NSMakeRange(0, [user.name length])];
        
        [oneComment addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor blackColor].CGColor range:NSMakeRange(0, [user.name length])];
        
        [oneComment addAttribute:(NSString*)kCTFontAttributeName value:(id)ctMainFont range:NSMakeRange([user.name length], [oneComment length]-[user.name length])];
        
        [contentString appendAttributedString:oneComment];
    }
    
    //get chatter string
    NSArray *chatters = (NSArray *)[dic objectForKey:@"chatters"];
    
    if (([chatters isKindOfClass:[NSArray class]]) && ([chatters count] > 0)) {
        //reverse order
        for (int i = [chatters count]-1; i>=0; i--) {
            //get content and user
            NSDictionary *aChatter = [chatters objectAtIndex:i];
            if (![aChatter isKindOfClass:[NSDictionary class]]) {
                NSLog(@"Bad format from CirkleDetail chatters array");
                continue;
            }
            //content
            NSString *aContent = [aChatter objectForKey:@"content"]; //no retain
            //user
            NSArray *aUser = [aChatter objectForKey:@"user"]; //no retain
            if (![aUser isKindOfClass:[NSArray class]]) {
                NSLog(@"Bad format from CirkleDetail chatter user");
                continue;
            }
            //first object is the user
            User *userObject = [aUser objectAtIndex:0];
            if (userObject) {
                //construct the string
                if (contentString==nil) {
                    contentString = [[NSMutableAttributedString alloc] init];
                }
                //[contentString appendFormat:@"%@:\n    %@\n", userObject.name, aContent];
                //NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:userObject.name, @"name", aContent, @"comment", nil];
                //[contentString addObject:dict];
                //[dict release];
                CTFontRef ctNameFont = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 
                                                            12, /*nameFont.pointSize, */
                                                            NULL);
                
                CTFontRef ctMainFont = CTFontCreateWithName(CFSTR("Helvetica"), 
                                                            12, /*mainFont.pointSize, */
                                                            NULL);
                
                NSString *fullcomment = [NSString stringWithFormat:@"%@: %@\n",userObject.name,aContent];
                
                NSMutableAttributedString *oneComment = [[NSMutableAttributedString alloc] initWithString:fullcomment];
                
                [oneComment addAttribute:(NSString*)kCTFontAttributeName value:(id)ctNameFont range:NSMakeRange(0, [userObject.name length])];
                
                [oneComment addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor blackColor].CGColor range:NSMakeRange(0, [userObject.name length])];
                
                [oneComment addAttribute:(NSString*)kCTFontAttributeName value:(id)ctMainFont range:NSMakeRange([userObject.name length], [oneComment length]-[userObject.name length])];
                
                [contentString appendAttributedString:oneComment];
            }
            //if anything goes wrong, do nothing in this for loop
        }
    } //end of get chatter string
    
    //NSLog(@"comments %@", contentString);
}

- (id)initWithJsonDictionary:(NSDictionary*)aDic {
    //get current time
    //time_t now;
    //time(&now);	
    
    size = CGSizeZero;
    
    //read type 
    NSString *eventType = [aDic objectForKey:@"type"];
    type = 0;
    
    //read ID at top level
    cId = [[aDic objectForKey:@"id"] longLongValue];
    
    //get time of the latest update - this time is refreshed
    struct tm   timeStruct;
    NSString* stringOftime = [aDic objectForKey:@"timestamp"] ;
    if ( stringOftime ) {
        strptime([stringOftime UTF8String], "%FT%T%z",  &timeStruct) ;
        timeAt   = timegm(&timeStruct);
    }
    
    if ([eventType isEqualToString:@"encounter"]) {
        //go down another layer
        NSDictionary *dic = [aDic objectForKey:@"encounter"];
        
        [self parseEncounter:dic];
        
    } else if ([eventType isEqualToString:@"topic"]) {
        NSDictionary *dic = [aDic objectForKey:@"topic"];
        
        [self parseTopic:dic];
    }
    //other types are ignored
    
    if ([contentString length] >0) {
        //framesetting
        framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentString);
    }
    return self;
}

@end

