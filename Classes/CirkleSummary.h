//
//  CirkleSummary.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/28/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "sqlite3.h"

@interface CirkleSummary : NSObject {
    sqlite_int64    cId;
    NSString        *nameString;
    NSString        *avatarUrl;
    time_t          timeAt;
    NSInteger       score;
    NSInteger       type;
    User            *user;
    NSMutableArray  *imageUrl;
    NSString        *contentString;
}

@property (nonatomic) sqlite_int64    cId;
@property (nonatomic, retain) NSString        *nameString;
@property (nonatomic, retain) NSString        *avatarUrl;
@property (nonatomic) time_t          timeAt;
@property (nonatomic) NSInteger       score;
@property (nonatomic) NSInteger       type;
@property (nonatomic, retain) User            *user;
@property (nonatomic, retain) NSMutableArray  *imageUrl;
@property (nonatomic, retain) NSString        *contentString;

- (id)initWithJsonDictionary:(NSDictionary*)dic;

@end