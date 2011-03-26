#import "News.h"

@implementation News

@synthesize data;

+ (NSString*)tableName
{
  return @"news";
}

+ (int)columnCount
{
  return [[super class] columnCount] + 1;
}

- (id)initWithData:(NSString*)data0 withId:(sqlite3_int64)id0 withOdd:(sqlite_int64)odd0
{
  [super initWithId:id0 withOdd:odd0];
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
  [stmt bindString:data forIndex:++index];
  return index;
}

@end
