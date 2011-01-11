//
//  meetDisplayMap.m
//  kaya_meet
//
//  Created by Jun Li on 12/27/10.
//

#import "meetDisplayMap.h"

@implementation meetDisplayMap

@synthesize coordinate;
@synthesize title,subtitle;

-(void)dealloc{
	[title release];
	[subtitle release];
	[super dealloc];
}

@end
