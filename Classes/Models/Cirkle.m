#import "Cirkle.h"

@implementation Cirkle

@synthesize data;

+ (NSString*)tableName
{
  return @"cirkles";
}

+ (int)columnCount
{
  return [[self superclass] columnCount] + 1;
}

- (id)initWithData:(NSDictionary*)data0 withId:(sqlite_uint64)id0 withOdd:(sqlite_uint64)odd0
{
  self = [super initWithId:id0 withOdd:odd0];
  if (self != nil) {
    self.data = data0;
  }
  return self;
}

- (id)initWithStmt:(Statement*)stmt
{
  self = [super initWithStmt:stmt];
  if (self != nil) {
    int index = [[self superclass] columnCount];
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
  [stmt bindString:[data serialize] forIndex:++index];
  return index;
}

@end
