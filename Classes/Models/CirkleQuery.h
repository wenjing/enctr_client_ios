#import <UIKit/UIkit.h>
#import "Cirkle.h"
#import "QueryProtocol.h"

@interface CirkleQuery : QueryBase
{
}
- (void)cirklesDidReceive:(KYMeetClient*)sender obj:(NSObject*)obj;
- (id)trimData:(id)obj;
- (id)expandData:(id)obj;
@end
