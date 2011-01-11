
// KYMeet.h
// kaya meet 
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "UserStore.h"
#import "Meet.h"

@class Statement;

#define IMAGE_PADDING       10
#define H_MARGIN            10
#define INDICATOR_WIDTH     (30 - H_MARGIN)
#define DETAIL_BUTTON_WIDTH (45 - H_MARGIN)

#define IMAGE_WIDTH         48
#define USER_CELL_LEFT      42
#define STAR_BUTTON_WIDTH   32

#define TOP                 (16 + 1)
#define LEFT                (IMAGE_PADDING * 2 + IMAGE_WIDTH)
#define CELL_WIDTH          (320 - LEFT)
#define TIMESTAMP_WIDTH     60
#define TIMESTAMP_LEFT      (LEFT + CELL_WIDTH) - TIMESTAMP_WIDTH

#define USER_CELL_WIDTH     (320 - USER_CELL_LEFT)
#define DETAIL_CELL_WIDTH   (300 - USER_CELL_LEFT)

typedef enum {
    MEET_ALL=0,
    MEET_SOLO,
    MEET_PRIVATE,
    MEET_GROUP
} KAYA_MEET_SHOW_TYPE;

@interface KYMeet : Meet
{
	User*			user  ; // to add Friends' meet 
	NSString*		place; // to display place
    NSString*       source;
	NSString*		latestChat;
}

@property (getter=_meetId, setter=setMeetId:) sqlite_int64  kymeetId;
@property (nonatomic, retain) User*         user;
@property (nonatomic, retain) NSString*     source;
@property (nonatomic, retain) NSString*      place;
@property (nonatomic, retain) NSString*      latestChat;

+ (KYMeet*)meetWithId:(sqlite_int64)kymeetId;
+ (KYMeet*)meetWithJsonDictionary:(NSDictionary*)dic type:(MeetType)type;
+ (KYMeet*)initWithStatement:(Statement*)statement;
+ (BOOL)isExists:(sqlite_int64)kymeetId;

- (id)initWithJsonDictionary:(NSDictionary*)dic type:(MeetType)type user:(User*)aUser;
- (id)initWithJsonDictionary:(NSDictionary*)dic type:(MeetType)type ;
- (id)initWithJsonDictionary:(NSDictionary*)dic ;
- (void)updateWithJsonDictionary:(NSDictionary*)dic ;

- (void)updateAttribute;
- (void)insertDB;
- (void)deleteFromDB;

+ (int )getMeetsFromDB:(NSMutableArray *)meets;

@end
