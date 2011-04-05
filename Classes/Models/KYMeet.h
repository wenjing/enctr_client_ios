
// KYMeet.h
// kaya meet 
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "UserStore.h"
#import "Meet.h"

@class Statement;

typedef enum {
    MEET_ALL=-1,
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

@property (getter=_meetId, setter=setMeetId:) sqlite_uint64  kymeetId;
@property (nonatomic, retain) User*         user;
@property (nonatomic, retain) NSString*     source;
@property (nonatomic, retain) NSString*      place;
@property (nonatomic, retain) NSString*      latestChat;

+ (KYMeet*)meetWithId:(sqlite_uint64)kymeetId;
+ (KYMeet*)meetWithJsonDictionary:(NSDictionary*)dic type:(MeetType)type;
+ (KYMeet*)initWithStatement:(Statement*)statement;
+ (BOOL)isExists:(sqlite_uint64)kymeetId;

- (id)initWithJsonDictionary:(NSDictionary*)dic type:(MeetType)type user:(User*)aUser;
- (id)initWithJsonDictionary:(NSDictionary*)dic type:(MeetType)type ;
- (id)initWithJsonDictionary:(NSDictionary*)dic ;
- (void)updateWithJsonDictionary:(NSDictionary*)dic ;

- (void)insertDB;
- (void)deleteFromDB;

+ (int )getMeetsFromDB:(NSMutableArray *)meets;

@end
