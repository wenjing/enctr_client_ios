//
//  UserStore.h
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserStore : NSObject {
}

+ (void)initDictionary;
+ (User*)getUser:(NSString*)screenName;
+ (User*)getUserWithId:(uint32_t)aId;
+ (void)setUser:(User*)user;
@end
