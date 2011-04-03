#import "News.h"

@implementation News

@synthesize userId;
@synthesize cirkleId;
@synthesize data;

+ (NSString*)tableName
{
  return @"news";
}

+ (int)columnCount
{
  return [[self superclass] columnCount] + 3;
}

- (id)initWithData:(NSDictionary*)data0 withId:(sqlite3_uint64)id0 withOdd:(sqlite_uint64)odd0
                                    withUserId:(sqlite_uint64)user_id
                                    withCirkleId:(sqlite_uint64)cirkle_id

{
  self = [super initWithId:id0 withOdd:odd0];
  if (self != nil) {
    self.userId = user_id;
    self.cirkleId = cirkle_id;
    self.data = data0;
  }
  return self;
}

- (id)initWithStmt:(Statement*)stmt
{
  self = [super initWithStmt:stmt];
  if (self != nil) {
    int index = [[self superclass] columnCount];
    self.userId   = [stmt getInt64:index++];
    self.cirkleId = [stmt getInt64:index++];
    self.data = [NSDictionary deserialize:[stmt getString:index++]];
  }
  return self;
}

- (void)dealloc
{
  self.data = nil;
  [super dealloc];
}

- (int)bindStmt:(Statement*)stmt isWithId:(BOOL)with_id
{
  int index = [super bindStmt:stmt isWithId:with_id];
  [stmt bindInt64:userId forIndex:++index];
  [stmt bindInt64:cirkleId forIndex:++index];
  [stmt bindString:[data serialize] forIndex:++index];
  return index;
}

@end
