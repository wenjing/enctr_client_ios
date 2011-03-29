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
@synthesize user;
@synthesize imageUrl;
@synthesize contentString;

- (id)initWithJsonDictionary:(NSDictionary*)dic {
    //get current time
    time_t now;
    time(&now);	
    
    cId = [[dic objectForKey:@"id"] longLongValue];
    
    nameString = [[dic objectForKey:@"name"] retain];
    
    score = [[dic objectForKey:@"relation_score"] intValue];
    
    struct tm   timeStruct;
    NSString* stringOftime = [dic objectForKey:@"timestamp"] ;
    if ( stringOftime ) {
		strptime([stringOftime UTF8String], "%FT%T%z",  &timeStruct) ;
		timeAt   = timegm(&timeStruct);
	}
    
    user = [[dic objectForKey:@"user"] retain];
    
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

            } else if ([actType isEqualToString:@"photo"]) {
                //read image url
                [imageUrl addObject: [[act objectForKey:@"url"] retain]]; //retain?
            }
            
        }
    }
    
    //make some fake contentString for testing
    if (cId % 2) {
		contentString = [[NSString alloc] initWithFormat:@"Jibber jabber gabble babble cackle clack prate twiddle twaddle mutter stutter utter splutter blate chatter patter tattle prattle chew the rag crack spiel spout spit it out tell the world and quack"];
	}
	else {
		contentString = [[NSString alloc] initWithFormat:@"I will see you on Monday!"];
	}
    
    return self;
}
@end
