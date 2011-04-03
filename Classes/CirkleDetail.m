//
//  CirkleDetail.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/30/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleDetail.h"


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
@synthesize contentString;

// Why isn't this in template?
- (void)dealloc
{
    [nameString release];
    [addrString release];
    [avatarUrl release];
    [user release];
    [imageUrl removeAllObjects];
    [imageUrl release];
    [contentString release];
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
        
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMM" options:0
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
    float longitude        = [[dic objectForKey:@"lng"]    floatValue] ;
    float latitude         = [[dic objectForKey:@"lat"]    floatValue] ;
    //to-do: cleanup
    NSString *headmapurl = @"http://maps.google.com/maps/api/staticmap?zoom=11&size=100x100&maptype=roadmap&format=png32&markers=color:green|size:small";
    
    NSString *mapurl = [NSString stringWithFormat:@"%@|%lf,%lf&sensor=false",headmapurl,latitude,longitude];
    
    mapurl = [mapurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"Map Url at model %@", mapurl);
    [imageUrl addObject:[NSString stringWithString:mapurl]];
    
    //get people image url
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
            }
        }
    }
    
    //get chatter string
    NSArray *chatters = (NSArray *)[dic objectForKey:@"chatters"];
    
    if (([chatters isKindOfClass:[NSArray class]]) && ([chatters count] > 0)) {
        for (int i = 0; i<[chatters count]; i++) {
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
                    contentString = [[NSMutableString alloc] initWithCapacity:20];
                }
                [contentString appendFormat:@"%@: %@\n", userObject.name, aContent];
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
    
    user = (User *)[userArray objectAtIndex:0];
    if (user != nil) {
        nameString = [[NSString alloc] initWithString:user.name];
        //no need for avatar - the view gets it directly from circleDetail object
        //avatarUrl = [NSURL URLWithString:[user.profileImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else {
        NSLog(@"Error reading user from topic dictionary");
    }
    
    NSLog(@"name %@",nameString);
        
    //init imageUrl
    imageUrl = [[NSMutableArray alloc] init];
    
    NSString *photoUrl = [dic objectForKey:@"chatter_photo"];
    if ((photoUrl) && [photoUrl isKindOfClass:[NSString class]]) {
        [imageUrl addObject:[photoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //first the content string at photo level
    NSString *tContent = [dic objectForKey:@"content"];
    if ((tContent) && [tContent isKindOfClass:[NSString class]]) {
        if (contentString==nil) {
            contentString = [[NSMutableString alloc] initWithCapacity:20];
        }
        
        [contentString appendFormat:@"%@: %@\n", user.name, tContent];
    }
    
    //get chatter string
    NSArray *chatters = (NSArray *)[dic objectForKey:@"chatters"];
    
    if (([chatters isKindOfClass:[NSArray class]]) && ([chatters count] > 0)) {
        for (int i = 0; i<[chatters count]; i++) {
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
                    contentString = [[NSMutableString alloc] initWithCapacity:20];
                }
                [contentString appendFormat:@"%@: %@\n", userObject.name, aContent];
            }
            //if anything goes wrong, do nothing in this for loop
        }
    } //end of get chatter string
    
    NSLog(@"comments %@", contentString);
}

- (id)initWithJsonDictionary:(NSDictionary*)aDic {
    //get current time
    time_t now;
    time(&now);	
    
    //Note: current return dictionary is in incorrect format. We will insist on correct format and ignore other results
    
    //read type 
    NSString *eventType = [aDic objectForKey:@"type"];
    type = 0;
    
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
    return self;
}

@end

