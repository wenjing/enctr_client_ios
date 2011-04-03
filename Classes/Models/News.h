#import <sys/time.h>
#import "RecordProtocol.h"

@interface News : RecordBase
{
  sqlite3_uint64 userId;
  sqlite3_uint64 cirkleId;
  NSDictionary *data;
}
@property (nonatomic, assign) sqlite3_uint64 userId;
@property (nonatomic, assign) sqlite3_uint64 cirkleId;
@property (nonatomic, retain) NSDictionary *data;
- (id)initWithData:(NSDictionary*)data0 withId:(sqlite_uint64)id0 withOdd:(sqlite_uint64)odd0
                                    withUserId:(sqlite_uint64)user_id
                                    withCirkleId:(sqlite_uint64)cirkle_id;
@end
