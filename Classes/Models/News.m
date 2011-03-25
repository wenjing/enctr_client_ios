#import "News.h"

@implementation News

@synthesize time;
@synthesize data;

+ (NSString*)tableName
{
  return @"news";
}

+ (int)columnCount
{
  return [[super class] columnCount] + 2;
}

- (id)initWithData:(NSString*)data0 withId:(sqlite3_int64)id0 withTime:(time_t)time0
{
  [super initWithId:id0];
  self.time = time0;
  self.data = data0;
  return self;
}

- (void)dealloc
{
  data = NULL;
  [super dealloc];
}

- (int)bindStmt:(Statement*)stmt
{
  int index = [super bindStmt:stmt];
  [stmt bindInt32:time forIndex:++index];
  [stmt bindString:data forIndex:++index];
  return index;
}

@end
