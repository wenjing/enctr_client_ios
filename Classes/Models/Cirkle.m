#import "Cirkle.h"

@implementation Cirkle

@synthesize type;
@synthesize score;
@synthesize data;

+ (NSString*)tableName
{
  return @"cirkles";
}

+ (int)columnCount
{
  return [[super class] columnCount] + 3;
}

- (id)initWithData:(NSString*)data0 withId:(sqlite_int64)id0 withType:(uint32_t)type0
                                    withScore:(uint32_t)score0
{
  [super initWithId:id0];
  self.type = type0;
  self.score = score0;
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
  [stmt bindInt32:type forIndex:++index];
  [stmt bindInt32:score forIndex:++index];
  [stmt bindString:data forIndex:++index];
  return index;
}

@end
