#import <UIKit/UIkit.h>
#import "News.h"
#import "QueryProtocol.h"

@interface NewsQuery : QueryBase
{
}
- (void)newsDidReceive:(KYMeetClient*)sender obj:(NSObject*)obj;
- (id)trimData:(id)obj;
@end
