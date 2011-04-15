//
//  CirkleMember.h
//  Cirkle
//
//  Created by Wenjing Chu on 4/12/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CirkleMember : NSObject {
    NSString *name;
    NSString *imageUrl;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *imageUrl;

- (id)initWithJsonDictionary:(NSDictionary*)dic;
@end
