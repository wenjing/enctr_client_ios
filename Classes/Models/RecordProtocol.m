#import <sys/time.h>
#import "DBConnection.h"
#import "RecordProtocol.h"

@implementation RecordBase

@synthesize id;

+ (NSString*)tableName
{
  return @"record_bases";
}

+ (int)columnCount
{
  return 1;
}

- (id)initWithId:(sqlite_int64)id0
{
  [super init];
  self.id = id0;
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (int)bindStmt:(Statement*)stmt
{
  int index = 0;
  [stmt bindString:[[self class] tableName] forIndex:++index];
  [stmt bindInt64:[self id] forIndex:++index];
  return index;
}

- (BOOL)insertDB
{
  static Statement *stmt = nil;
  if (stmt == nil) {
    NSString *pad_str = @"?,";
    uint64_t pad_len = [[self class] columnCount] * [pad_str length] - 1;
    NSString *stmt_str = @"REPLACE INTO ? VALUES(";
    stmt_str = [stmt_str stringByPaddingToLength:([stmt_str length]+pad_len)
                         withString:pad_str startingAtIndex:0];
    stmt_str = [stmt_str stringByAppendingString:@")"];
    stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
    [stmt retain];
  }
  [self bindStmt:stmt];
  BOOL res = ([stmt step] == SQLITE_DONE);
  [stmt reset];
  //[DBConnection alert];
  //will add user in the future
  //[user updateDB];
  return res;
}

- (BOOL)deleteFromDB
{
  static Statement *stmt = nil;
  if (stmt == nil) {
    stmt = [DBConnection statementWithQuery:"DELETE FROM ? WHERE id = ?"];
    [stmt retain];
  }
  [stmt bindString:[[self class] tableName] forIndex:1];
  [stmt bindInt64:[self id] forIndex:2];
  [stmt step]; // ignore error
  return true;
}

@end
