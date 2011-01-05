//
//  placeDisplayMap.m
//  kaya_meet
//
//  Created by Jun Li on 12/27/10.
//

#import "placeDisplayMap.h"

@implementation placeDisplayMap

@synthesize coordinate,dataid,dataType;
@synthesize title,subtitle;

-(void)dealloc{
	[title release];
	[subtitle release];
	[super dealloc];
}

@end
