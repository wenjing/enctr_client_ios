#import <sys/time.h>
#import "RecordProtocol.h"

@interface Cirkle : RecordBase
{
  NSDictionary *data;
}
@property (nonatomic, retain) NSDictionary *data;
+ (int)columnCount;
- (id)initWithData:(NSDictionary*)data0 withId:(sqlite_uint64)id0 withOdd:(sqlite_uint64)odd0;
@end
