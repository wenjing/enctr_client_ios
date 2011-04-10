//
//  CirkleSummary.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/28/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleSummary.h"
#import "TimeUtils.h"
#import "StringUtil.h"

@implementation CirkleSummary
@synthesize cId;
@synthesize nameString;
//@synthesize avatarUrl;
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
    //[avatarUrl release]; not used
    [user release];
    [imageUrl removeAllObjects];
    [imageUrl release];
    [contentString release];
    [super dealloc];
}

- (id)initWithJsonDictionary:(NSDictionary*)dic {
    //get current time
    time_t now;
    time(&now);	
    
    cId = [[dic objectForKey:@"id"] longLongValue];
    
    NSString *typeString = [dic objectForKey:@"type"]; 
    
    if ([typeString isEqualToString:@"private"]) {
        type = CIRCLE_TYPE_PRIVATE;
    } else if ([typeString isEqualToString:@"cirkle"]) {
        type = CIRCLE_TYPE_CIRCLE;
    } else if ([typeString isEqualToString:@"solo"]) {
        type = CIRCLE_TYPE_SOLO;
    } else {
        NSLog(@"Incorrect circle summary type string");
    }
    
    nameString = [[dic objectForKey:@"name"] retain];
    
    score = [[dic objectForKey:@"relation_score"] intValue];
    
    struct tm   timeStruct;
    NSString* stringOftime = [dic objectForKey:@"timestamp"] ;
    if ( stringOftime ) {
		strptime([stringOftime UTF8String], "%FT%T%z",  &timeStruct) ;
		timeAt   = timegm(&timeStruct);
	}
    
    user = [[dic objectForKey:@"user"] retain];
    
    //NSLog(@"Parse circle: user profile image url %@", user.profileImageUrl);
    
    imageUrl = [[NSMutableArray alloc] init];
    
    NSArray *acts = (NSArray *)[dic objectForKey:@"activities"];
    
    if ([acts isKindOfClass:[NSArray class]]) {
        for (int i=0; i<[acts count]; i++) {
            //read type first
            NSDictionary *act = (NSDictionary*)[acts objectAtIndex:i] ;
			if (![act isKindOfClass:[NSDictionary class]]) {
                NSLog(@"Bad format from CirkleSummary dictionary activities array");
				continue;
			}
            NSString *actType = [act objectForKey:@"type"];
            if ([actType isEqualToString:@"encounter"]) {
                //read lat and lng
                float longitude        = [[act objectForKey:@"lng"]    floatValue] ;
                float latitude         = [[act objectForKey:@"lat"]    floatValue] ;
                // get url, to-do: cleanup
                NSString *headmapurl = @"http://maps.google.com/maps/api/staticmap?zoom=11&size=100x100&maptype=roadmap&format=png32&markers=color:green|size:small";
                
                NSString *mapurl = [NSString stringWithFormat:@"%@|%lf,%lf&sensor=false",headmapurl,latitude,longitude];
                
                mapurl = [mapurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                [imageUrl addObject:[NSString stringWithString:mapurl]];
                
                //pick the first act
                if (contentString==nil) {
                    time_t encounterTime;
                    
                    NSString *stringtime = [act objectForKey:@"timestamp"] ;
                    struct tm structtm;
                    
                    if ( stringtime ) {
                        strptime([stringtime UTF8String], "%FT%T%z",  &structtm) ;
                        encounterTime   = timegm(&structtm);
                    
                        static NSDateFormatter *dateFormatter = nil;
                        if (dateFormatter == nil) {
                            dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                        }
                        
                        NSDate *date = [NSDate dateWithTimeIntervalSince1970:encounterTime];        
                        NSString *timeString = [dateFormatter stringFromDate:date];
                        
                        contentString = [[NSString alloc] initWithFormat:@"Encounter at %@", timeString];
                    }
                }
                
            } else if ([actType isEqualToString:@"photo"]) {
                //read image url
                [imageUrl addObject: [[act objectForKey:@"url"] retain]]; //retain
                //pick the first act
                if (contentString==nil) {
                    NSString *photoString = [act objectForKey:@"content"];
                    User *poster = [act objectForKey:@"user"];
                    
                    if (poster) {
                        contentString = [[NSString alloc] initWithFormat:@"%@ shared photo: \"%@\".", poster.name, photoString];
                    } else {
                        contentString = [[NSString alloc] initWithFormat:@"Photo shared: \"%@\".", photoString];
                    }
                }

            }
            
        }
        
    }
    
    //NSLog(@"contentString is %@", contentString);
    return self;
}

- (BOOL)isACircle {
    return (type == CIRCLE_TYPE_CIRCLE);
}

@end
