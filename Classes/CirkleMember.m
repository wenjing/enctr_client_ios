//
//  CirkleMember.m
//  Cirkle
//
//  Created by Wenjing Chu on 4/12/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleMember.h"
#import "User.h"

@implementation CirkleMember
@synthesize name;
@synthesize imageUrl;

- (id)initWithJsonDictionary:(NSDictionary*)aDic {
    
    NSString *eventType = [aDic objectForKey:@"type"];
    if ([eventType isEqualToString:@"users"]) {
        NSLog(@"Parsing a users record");
    }
    
    NSArray *users = (NSArray *)[aDic objectForKey:@"users"];
    if (![users isKindOfClass:[NSArray class]]) {
        NSLog(@"Bad format from member users array");
    }
    
    NSArray *aUserArray;
    for (aUserArray in users) {
        if (![aUserArray isKindOfClass:[NSArray class]]) {
            NSLog(@"Bad format from member user array");
        }
        
        //now the user - retain it
        User *aUser = [[aUserArray objectAtIndex:0] retain];
    }
    
    return self;
}

- (void)dealloc {
    [name release];
    [imageUrl release];
    [super dealloc];
    
}
@end
