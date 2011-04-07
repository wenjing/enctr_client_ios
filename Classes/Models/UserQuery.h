#import <UIKit/UIkit.h>
#import "Cirkle.h"
#import "QueryProtocol.h"

@interface UserQuery : QueryBase
{
}
- (void)usersDidReceive:(KYMeetClient*)sender obj:(NSObject*)obj;
- (void)usersDidSave:(KYMeetClient*)sender obj:(NSObject*)obj;
@end
