#import <UIKit/UIkit.h>
#import "Cirkle.h"
#import "QueryProtocol.h"

@interface CirkleQuery : QueryBase
{
}
- (id)recordClass;
- (void)cirklesDidReceive:(KYMeetClient*)sender obj:(NSObject*)obj;
- (id)trimData:(id)obj;
@end
