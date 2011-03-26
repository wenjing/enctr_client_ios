#import <sys/time.h>
#import "RecordProtocol.h"

@interface News : RecordBase
{
  time_t time;
  NSString *data;
}
@property (nonatomic, assign) time_t    time;
@property (nonatomic, retain) NSString  *data;
- (id)initWithData:(NSString*)data0 withId:(sqlite_int64)id0 withTime:(time_t)time0;
@end
