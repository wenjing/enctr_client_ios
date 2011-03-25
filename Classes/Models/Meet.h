


#import <UIKit/UIKit.h>
#import "sqlite3.h"

#define NUM_MEET_PER_PAGE    20

typedef enum {
    KYMEET_TYPE_SENT=0,
    KYMEET_TYPE_UPDATE,
	KYMEET_TYPE_TEMP
} MeetType;

@interface Meet : NSObject
{
    sqlite_int64    meetId;  // Server meet id
	sqlite_int64    postId;  // Post meet id 
	NSString*       description;   // meet description
    
    time_t          timeAt, updateAt;
    NSString*       timestamp ;
	float 		    longitude, latitude;
    MeetType        type;
	int				userCount ;
    NSMutableArray* meetUsers ;
}

@property (nonatomic, assign) sqlite_int64      meetId, postId;
@property (nonatomic, retain) NSString*         description;

@property (nonatomic, assign) time_t            updateAt, timeAt;
@property (nonatomic, assign) float         longitude, latitude;
@property (nonatomic, retain) NSString*     timestamp;
@property (nonatomic, assign) MeetType       type;
@property (nonatomic, assign) int			userCount;
@property (nonatomic, retain) NSMutableArray *meetUsers;

- (NSString*) timestamp;

@end
