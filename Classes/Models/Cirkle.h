#import <sys/time.h>
#import "RecordProtocol.h"

@interface Cirkle : RecordBase
{
  NSString *data;
}
@property (nonatomic, retain) NSString  *data;
- (id)initWithData:(NSString*)data0 withId:(sqlite_int64)id0 withOdd:(sqlite_int64)odd0;
@end
