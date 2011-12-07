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
@synthesize avatarUrl;
@synthesize timeAt;
@synthesize score;
@synthesize type;
@synthesize inviter;
@synthesize imageUrl;
@synthesize contentString;
@synthesize size;

// Why isn't this in template?
- (void)dealloc
{
    [nameString release];
    [avatarUrl release];
    [inviter release];
    [imageUrl removeAllObjects];
    [imageUrl release];
    [contentString release];
    [super dealloc];
}

- (id)initWithJsonDictionary:(NSDictionary*)dic {
    //get current time
    time_t now;
    time(&now);	
    
    size = CGSizeZero;
    
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
    
    struct tm   timeStruct;
    NSString* stringOftime = [dic objectForKey:@"timestamp"] ;
    if ( stringOftime ) {
		strptime([stringOftime UTF8String], "%FT%T%z",  &timeStruct) ;
		timeAt   = timegm(&timeStruct);
	}
    
    nameString = [[dic objectForKey:@"name"] retain];
    
    if (type == CIRCLE_TYPE_CIRCLE) {
        NSInteger is_pending = [[dic objectForKey:@"is_pending"] intValue];
        if (is_pending == 1) {
            //invitation:
            type = CIRCLE_TYPE_INVITE;
            //contentString = invite_message
            inviter = [[dic objectForKey:@"inviter"] retain];
            contentString = [[dic objectForKey:@"invite_message"] retain];
            NSString *profileString = [inviter.profileImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            avatarUrl = [[NSURL URLWithString:profileString] retain];
            
            imageUrl = [[NSMutableArray alloc] init]; //empty
            return self;
        }
    }
    
    //BUG: server sometimes not returning valid value
    
    score = 2; //[[dic objectForKey:@"relation_score"] intValue];
    
    //user = [[dic objectForKey:@"user"] retain]; //we don't use this anymore
    NSString *urlString = [[dic objectForKey:@"image"] retain];
    
    //NSLog(@"Parse circle: user profile image url %@", urlString);
    NSString *profileString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    avatarUrl = [[NSURL URLWithString:profileString] retain];
    
    //Display Me if it's myself
    if (type==CIRCLE_TYPE_SOLO) {
        //overwrite nameString
        nameString = [[NSString alloc] initWithFormat:@"Me, Myself and I"];
    }
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
                float longitude;
                if ([act objectForKey:@"lng"]!= nil && [act objectForKey:@"lng"]!= [NSNull null])
                    longitude = [[act objectForKey:@"lng"]    floatValue] ;
                
                float latitude;
                if ([act objectForKey:@"lat"]!= nil && [dic objectForKey:@"lat"]!= [NSNull null])
                    latitude = [[act objectForKey:@"lat"]    floatValue] ;
                
                // get url, to-do: cleanup
                NSString *headmapurl = @"http://maps.google.com/maps/api/staticmap?zoom=11&size=100x100&maptype=roadmap&format=png32&markers=color:green|size:small";
                
                NSString *mapurl = [NSString stringWithFormat:@"%@|%lf,%lf&sensor=false",headmapurl,latitude,longitude];
                
                mapurl = [mapurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                [imageUrl addObject:[NSURL URLWithString:mapurl]];
                
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
                NSString *urlstring = [[act objectForKey:@"url"] retain];
                [imageUrl addObject: [NSURL URLWithString:urlstring]];
                //pick the first act
                if (contentString==nil) {
                    NSString *photoString = [act objectForKey:@"content"];
                    User *poster = [act objectForKey:@"user"];
                    if (photoString==nil || [photoString isEqualToString:@""]) {
                        photoString = [NSString stringWithString:@"Untitled"];
                    }
                    if (poster) {
                        contentString = [[NSString alloc] initWithFormat:@"%@ shared a photo: \"%@\"", poster.name, photoString];
                    } else {
                        contentString = [[NSString alloc] initWithFormat:@"Photo shared: \"%@\"", photoString];
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
