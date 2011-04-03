//
//  CirkleDetail.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/30/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "sqlite3.h"

#define CD_TYPE_ENCOUNETR   1
#define CD_TYPE_TOPIC       2

@interface CirkleDetail : NSObject {
    sqlite_int64    cId;
    NSString        *nameString;
    NSString        *addrString;
    NSString        *avatarUrl;
    time_t          timeAt;
    NSInteger       score;
    NSInteger       type;
    User            *user;
    NSMutableArray  *imageUrl;
    NSMutableString *contentString;

}
@property (nonatomic) sqlite_int64    cId;
@property (nonatomic, retain) NSString        *nameString;
@property (nonatomic, retain) NSString        *addrString;
@property (nonatomic, retain) NSString        *avatarUrl;
@property (nonatomic) time_t          timeAt;
@property (nonatomic) NSInteger       score;
@property (nonatomic) NSInteger       type;
@property (nonatomic, retain) User            *user;
@property (nonatomic, retain) NSMutableArray  *imageUrl;
@property (nonatomic, retain) NSMutableString *contentString;

- (id)initWithJsonDictionary:(NSDictionary*)dic;

@end
