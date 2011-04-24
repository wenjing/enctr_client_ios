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
#import <CoreText/CoreText.h>

#define CD_TYPE_ENCOUNETR   1
#define CD_TYPE_TOPIC       2

@interface CirkleDetail : NSObject {
    sqlite_uint64    cId;
    NSString        *nameString;
    NSString        *addrString;
    NSString        *avatarUrl;
    time_t          timeAt;
    NSInteger       score;
    NSInteger       type;
    User            *user;
    NSMutableArray  *imageUrl;
    NSMutableAttributedString *contentString;
    CTFramesetterRef framesetter;
    CGSize          size;
    float           latitude;
    float           longitude;
}
@property (nonatomic) sqlite_uint64    cId;
@property (nonatomic, retain) NSString        *nameString;
@property (nonatomic, retain) NSString        *addrString;
@property (nonatomic, retain) NSString        *avatarUrl;
@property (nonatomic) time_t          timeAt;
@property (nonatomic) NSInteger       score;
@property (nonatomic) NSInteger       type;
@property (nonatomic, retain) User            *user;
@property (nonatomic, retain) NSMutableArray  *imageUrl;
@property (nonatomic, retain) NSMutableAttributedString *contentString;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) CGSize size;


- (id)initWithJsonDictionary:(NSDictionary*)dic;
- (CTFramesetterRef) getFramesetter;

@end
