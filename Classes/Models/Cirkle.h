#import <sys/time.h>
#import "RecordProtocol.h"

@interface Cirkle : RecordBase
{
  uint32_t type;
  uint32_t score;
  NSString *data;
}
@property (nonatomic, assign) uint32_t  type;
@property (nonatomic, assign) uint32_t  score;
@property (nonatomic, retain) NSString  *data;
- (id)initWithData:(NSString*)data0 withId:(sqlite_int64)id0 withType:(uint32_t)type0
                                    withScore:(uint32_t)score0;
@end
