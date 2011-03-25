// user.h
// kaya meet User profile
//
//


#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface User : NSObject
{
	uint32_t    userId;
    NSString*   name;
	NSString*   screenName;
	NSString*	email;
	NSString*   location;
	NSString*   profileImageUrl;
    uint32_t    meetsCount;
    BOOL        notifications;
}

@property (nonatomic, assign) uint32_t  userId;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* screenName;
@property (nonatomic, retain) NSString* email;
@property (nonatomic, retain) NSString* location;
@property (nonatomic, assign) uint32_t  meetsCount;
@property (nonatomic, retain) NSString* profileImageUrl;
@property (nonatomic, assign) BOOL      notifications;

+ (User*)userWithId:(uint32_t)aId;
+ (User*)userWithJsonDictionary:(NSDictionary*)dic;

- (id)initWithJsonDictionary:(NSDictionary*)dic;
- (void)updateWithJSonDictionary:(NSDictionary*)dic;
- (void)updateDB;

@end
