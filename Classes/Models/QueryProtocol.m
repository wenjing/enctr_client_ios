#import "QueryProtocol.h"

@implementation QueryBase

@synthesize delegate;
@synthesize action;
@synthesize results;

- (id)initWithDelegate:(id)delegate0 action:(SEL)action0
{
  [super init];
  self.delegate = delegate0;
  self.action = action0;
  [self clear];
  return self;
}
- (void)dealloc
{
  self.results = nil; 
  [super dealloc];
}

- (id) recordClass;
{
  return [RecordBase class];
}

- (BOOL)isExists:(sqlite_int64)aId
{
  static Statement *stmt = nil;
  if (stmt == nil) {
      stmt = [DBConnection statementWithQuery:"SELECT id FROM ? WHERE id=?"];
      [stmt retain];
    }
  [stmt bindString:[[self recordClass] tableName] forIndex:1];
  [stmt bindInt64:aId forIndex:2];
  BOOL result = ([stmt step] == SQLITE_ROW) ? true : false;
  [stmt reset];
  return result;
}

- (NSArray*)getResult
{
  return [self results];
}
- (BOOL)hasMore
{
  return more;
}
- (void)clear
{
  self.results = nil;
  more = false;
}

@end
