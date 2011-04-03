#import <sys/time.h>
#import <math.h>
#import "JSON.h"
#import "DBConnection.h"
#import "RecordProtocol.h"

@implementation NSObject (Serialize)
- (id)serialize
{
  SBJsonWriter *json_writer = [[SBJsonWriter alloc] init];
  NSString *res = [json_writer stringWithObject:self];
  [json_writer release];
  return res;
}
+ (id)deserialize:(id)from
{
  return [(NSString*)from JSONValue];
}
@end

@implementation RecordBase

@synthesize kid;
@synthesize odd;

+ (NSString*)tableName
{
  return @"record_bases";
}

+ (int)columnCount
{
  return 2;
}

- (id)initWithId:(sqlite_uint64)id0 withOdd:(sqlite_uint64)odd0
{
  self = [super init];
  if (self != nil) {
    self.kid = id0;
    self.odd = odd0;
  }
  return self;
}

- (id)initWithStmt:(Statement*)stmt
{
  self = [super init];
  if (self != nil) {
    int index = 0;
    self.kid = [stmt getInt64:index++];
    self.odd = [stmt getInt64:index++];
  }
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (int)bindStmt:(Statement*)stmt isWithId:(BOOL)with_id
{
  int index = 0;
  if (with_id) [stmt bindInt64:kid forIndex:++index];
  [stmt bindInt64:odd forIndex:++index];
  return index;
}

+ (int)countDB:(NSString*)estmt withOffset:(int)offset withLimit:(int)limit
{
  if (offset < 0) offset = 0;
  if (limit < 0) limit = 1000000;
  NSString *stmt_str = [NSString stringWithFormat:@"SELECT count(id) FROM %@ %@ ORDER BY %s DESC LIMIT %d OFFSET %d",
                                                  [[self class] tableName], estmt, "odd", limit, offset];
  Statement *stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
  int ret = [stmt step];
  if (ret != SQLITE_ROW) return -1;
  return [stmt getInt32:0];
}

+ (NSArray*)queryDB:(NSString*)estmt withOffset:(int)offset withLimit:(int)limit
{
  if (offset < 0) offset = 0;
  if (limit < 0) limit = 1000000;
  NSString *stmt_str = [NSString stringWithFormat:@"SELECT * FROM %@ %@ ORDER BY %s DESC LIMIT %d OFFSET %d",
                                                  [[self class] tableName], estmt, "odd", limit, offset];
  Statement *stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
  NSMutableArray *res = [NSMutableArray arrayWithCapacity:(limit<1024?limit:1024)];
  while (1) {
    int ret = [stmt step];
    if (ret != SQLITE_ROW) break;
    id item = [[[self class] alloc] initWithStmt:stmt];
    [res addObject:item];
    [item release];
  }
  return res;
}

+ (BOOL)deleteAllDB:(NSString*)estmt
{
  NSString *stmt_str = [NSString stringWithFormat:@"DELETE FROM %@ %@",
                                                  [[self class] tableName], estmt];
  Statement *stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
  //[DBConnection beginTransaction];
  [stmt step]; // ignore error
  //[DBConnection commitTransaction];
  return true;
}

+ (id)findDB:(sqlite_uint64)id0
{
  NSString *stmt_str = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id = ?",
                                                  [[self class] tableName]];
  Statement *stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
  [stmt bindInt64:id0 forIndex:1];
  int ret = [stmt step];
  if (ret != SQLITE_ROW) {
     [stmt reset];
     return nil;
  }
  id res = [[[[self class] alloc] initWithStmt:stmt] autorelease];
  [stmt reset];
  return res;
}

+ (BOOL)isExistInDB:(sqlite_uint64)id0
{
  NSString *stmt_str = [NSString stringWithFormat:@"SELECT id FROM %@ WHERE id = ?",
                                                  [[self class] tableName]];
  Statement *stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
  [stmt bindInt64:id0 forIndex:1];
  BOOL result = ([stmt step] == SQLITE_ROW) ? true : false;
  [stmt reset];
  return result;
}

- (BOOL)persist
{
  NSString *pad_str = @"?,";
  BOOL res = false;
  if (kid > 0) {
    uint64_t pad_len = [[self class] columnCount] * [pad_str length] - 1;
    NSString *stmt_str = [NSString stringWithFormat:@"REPLACE INTO %@ VALUES(",
                                                    [[self class] tableName]];
    stmt_str = [stmt_str stringByPaddingToLength:([stmt_str length]+pad_len)
                                                  withString:pad_str startingAtIndex:0];
    stmt_str = [stmt_str stringByAppendingString:@")"];
    Statement *stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
    [self bindStmt:stmt isWithId:true];
    //[DBConnection beginTransaction];
    res = ([stmt step] == SQLITE_DONE);
    //NSLog(@"%d %s", xxx, sqlite3_errmsg([DBConnection getSharedDatabase]));
    //[DBConnection commitTransaction];
    [stmt reset];

  } else { // New record
    uint64_t pad_len = ([[self class] columnCount]-1) * [pad_str length] - 1;
    NSString *stmt_str = [NSString stringWithFormat:@"REPLACE INTO %@ VALUES(NULL",
                                                    [[self class] tableName]];
    stmt_str = [stmt_str stringByPaddingToLength:([stmt_str length]+pad_len)
                                                  withString:pad_str startingAtIndex:0];
    stmt_str = [stmt_str stringByAppendingString:@")"];
    Statement *stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
    [self bindStmt:stmt isWithId:false];
    //[DBConnection beginTransaction];
    res = ([stmt step] == SQLITE_DONE);
    //[DBConnection commitTransaction];
    if (res) self.kid = [DBConnection lastInsertId];
    [stmt reset];
  }
  //[DBConnection alert];
  return res;
}

+ (BOOL)isExist:(id)key
{
  sqlite_uint64 id0 = [key integerValue];
  return [[self class] isExistInDB:id0];
}

+ (id)retrieve:(id)key
{
  sqlite_uint64 id0 = [key integerValue];
  return [[self class] findDB:id0];
}

- (BOOL)delete
{
  NSString *stmt_str = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = ?",
                                                  [[self class] tableName]];
  Statement *stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
  [stmt bindInt64:kid forIndex:1];
  //[DBConnection beginTransaction];
  [stmt step]; // ignore error
  //[DBConnection commitTransaction];
  return true;
}

@end
