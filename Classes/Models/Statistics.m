#import "JSON.h"
#import "Statistics.h"
#import "DBConnection.h"
#import "Singleton.h"

@implementation StatBase
@synthesize subKey;
- (id)init
{
  self = [super init];
  if (self != nil) {
    self.subKey = nil;
  }
  return self;
}
- (void)dealloc
{
  self.subKey = nil;
  [super dealloc];
}
+ (NSString*) keyName
{
  return @"base";
}
+ (BOOL) isExist:(id)sub_key
{
  NSString *str = [[Statistics sharedStatistics]
                      objectForKey:[[self class] keyName] withSubKey:sub_key];
  return str != nil;
}
+ (id) retrieve:(id)sub_key
{
  NSDictionary *dic = [[Statistics sharedStatistics]
                        objectForKey:[[self class] keyName] withSubKey:sub_key];
  StatBase *res = nil;
  if (dic) {
    res = [[self class] deserialize:dic];
  } else { // return an empty one
    res = [[[[self class] alloc] init] autorelease];
  }
  res.subKey = sub_key;
  return res;
}
- (BOOL) persist
{
  return [[Statistics sharedStatistics]
                      setObject:[self serialize]
                      forKey:[[self class] keyName] withSubKey:subKey];
}
- (BOOL) delete
{
  return [[Statistics sharedStatistics]
                      removeObjectForKey:[[self class] keyName] withSubKey:subKey];
}
@end

@implementation CirkleStat
@synthesize lastQuery;
@synthesize latestTime;
@synthesize earliestTime;
+ (NSString*)keyName
{
  return @"cirkle";
}
- (id)init
{
  self = [super init];
  if (self != nil) {
    self.lastQuery = self.latestTime = self.earliestTime = 0;
  }
  return self;
}
- (void)dealloc
{
  [super dealloc];
}
+ (id)deserialize:(id)from
{
  NSDictionary *dic = (NSDictionary*)from;
  CirkleStat *cirkle = [[[CirkleStat alloc] init] autorelease];
  cirkle.lastQuery    = (time_t)[[dic objectForKey:@"lq"] longLongValue];
  cirkle.latestTime   = (time_t)[[dic objectForKey:@"lt"] longLongValue];
  cirkle.earliestTime = (time_t)[[dic objectForKey:@"et"] longLongValue];
  return cirkle;
}
- (id)serialize
{
  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%qu", lastQuery],    @"lq", 
                        [NSString stringWithFormat:@"%qu", latestTime],   @"lt", 
                        [NSString stringWithFormat:@"%qu", earliestTime], @"et", 
                        nil];
  return dic;
}
@end

@implementation NewsStat
@synthesize lastQuery;
@synthesize latestTime;
@synthesize earliestTime;
@synthesize hasMore;
+ (NSString*)keyName
{
  return @"news";
}
- (id)init
{
  self = [super init];
  if (self != nil) {
    self.lastQuery = self.latestTime = self.earliestTime = 0;
    self.hasMore = true;
  }
  return self;
}
- (void)dealloc
{
  [super dealloc];
}
+ (id)deserialize:(id)from
{
  NSDictionary *dic = (NSDictionary*)from;
  NewsStat *news = [[[NewsStat alloc] init] autorelease];
  news.lastQuery    = (time_t)[[dic objectForKey:@"lq"] longLongValue];
  news.latestTime   = (time_t)[[dic objectForKey:@"lt"] longLongValue];
  news.earliestTime = (time_t)[[dic objectForKey:@"et"] longLongValue];
  news.hasMore      = (BOOL)  [[dic objectForKey:@"hm"] boolValue];
  return news;
}
- (id)serialize
{
  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%qu", lastQuery],    @"lq",
                        [NSString stringWithFormat:@"%qu", latestTime],   @"lt",
                        [NSString stringWithFormat:@"%qu", earliestTime], @"et",
                        [NSString stringWithFormat:@"%s",  hasMore?"T":"F"], @"hm",
                        nil];
  return dic;
}
@end

@implementation MiscStat
+ (NSString*)keyName
{
  return @"misc";
}
- (id)init
{
  self = [super init];
  if (self != nil) {
  }
  return self;
}
- (void)dealloc
{
  [super dealloc];
}
+ (id)deserialize:(id)from
{
  //NSDictionary *dic = (NSDictionary)from;
  MiscStat *misc = [[[MiscStat alloc] init] autorelease];
  return misc;
}
- (id)serialize
{
  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
  return dic;
}
@end

@implementation Statistics
SYNTHESIZE_SINGLETON_FOR_CLASS(Statistics);

@synthesize data;

+ (NSString*)tableName
{
  return @"statistics";
}

+ (int)columnCount
{
  return [[self superclass] columnCount] + 3;
}

- (id)init
{
  self = [super initWithId:1 withOdd:0];
  if (self != nil) {
    [self clear];
  }
  return self;
}
- (void)dealloc
{
  self.data = nil;
  [super dealloc];
}
- (void)clear
{
  self.data = nil;
  self.data = [NSMutableDictionary dictionary];
  [DBConnection beginTransaction];
  [self synchronize];
  [DBConnection commitTransaction];
}

- (void)synchronize
{
  if (![self load]) {
    self.data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [NSMutableDictionary dictionary], [CirkleStat keyName],
                        [NSMutableDictionary dictionary], [NewsStat keyName],
                        [NSMutableDictionary dictionary], [MiscStat keyName],
                        nil];
    [self save];
  }
}

- (BOOL)load
{
  static Statement *stmt = nil;
  if (!stmt) {
    NSString *stmt_str = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id = ?",
                                                    [[self class] tableName]];
    stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
    [stmt retain];
  }
  [stmt bindInt64:kid forIndex:1];
  int ret = [stmt step];
  if (ret != SQLITE_ROW) {
     [stmt reset];
     return false;
  }
  [self initWithStmt:stmt];
  [stmt reset];
  return true;
}

- (BOOL)save
{
  return [self persist];
  /*static Statement *stmt = nil;
  if (!stmt) {
    NSString *stmt_str = [NSString stringWithFormat:@"REPLACE INTO %@ WHERE id = ?",
                                                    [[self class] tableName]];
    stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
    [stmt retain];
  }
  [stmt bindInt64:kid forIndex:1];
  //[DBConnection beginTransaction];
  BOOL res = ([stmt step] == SQLITE_DONE);
  //[DBConnection commitTransaction];
  [stmt reset];
  return res;*/
}

- (BOOL)loadForKey:(NSString*)key
{
  NSString *stmt_str = [NSString stringWithFormat:@"SELECT (%@) FROM %@ WHERE id = ?",
                                                  key, [[self class] tableName]];
  Statement *stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
  [stmt bindString:key forIndex:1];
  [stmt bindInt64:kid forIndex:2];
  int ret = [stmt step];
  if (ret != SQLITE_ROW) {
     [stmt reset];
     return false;
  }
  [data setObject:[NSMutableDictionary deserialize:[stmt getString:0]] forKey:key];
  [stmt reset];
  return true;
}

- (BOOL)save:(id)obj forKey:(NSString*)key
{
  if (!obj) return true;
  NSString *stmt_str = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ? WHERE id = ?",
                                                  [[self class] tableName], key];
  Statement *stmt = [DBConnection statementWithQuery:[stmt_str UTF8String]];
  [stmt bindString:[obj serialize] forIndex:1];
  [stmt bindInt64:kid forIndex:2];
  //[DBConnection beginTransaction];
  BOOL res = ([stmt step] == SQLITE_DONE);
  //[DBConnection commitTransaction];
  [stmt reset];
  return res;
}

- (id)initWithStmt:(Statement*)stmt
{
  self = [super initWithStmt:stmt];
  if (self != nil) {
    int index = [[self superclass] columnCount];
    [data setObject:[NSMutableDictionary deserialize:[stmt getString:index++]]
                    forKey:[CirkleStat keyName]];
    [data setObject:[NSMutableDictionary deserialize:[stmt getString:index++]]
                    forKey:[NewsStat keyName]];
    [data setObject:[NSMutableDictionary deserialize:[stmt getString:index++]]
                    forKey:[MiscStat keyName]];
  }
  return self;
}

- (int)bindStmt:(Statement*)stmt isWithId:(BOOL)with_id
{
  int index = [super bindStmt:stmt isWithId:with_id];
  [stmt bindString:[[data objectForKey:[CirkleStat keyName]] serialize]
                   forIndex:++index];
  [stmt bindString:[[data objectForKey:[NewsStat keyName]] serialize]
                   forIndex:++index];
  [stmt bindString:[[data objectForKey:[MiscStat keyName]] serialize]
                   forIndex:++index];
  return index;
}

- (id)objectForKey:(NSString*)key withSubKey:(NSString*)sub_key
{
  //if (![self loadForKey:key]) return nil; 
  NSDictionary *item = [data objectForKey:key];
  if (!item || !sub_key) return item;
  return [item objectForKey:sub_key];
}

- (BOOL)setObject:(id)obj forKey:(NSString*)key withSubKey:(NSString*)sub_key
{
  NSMutableDictionary *item;
  if (!sub_key) {
    [data setObject:obj forKey:key];
    item = [data objectForKey:key];
  } else {
    item = [data objectForKey:key];
    if (!item) {
      item = [NSMutableDictionary dictionary];
      [data setObject:item forKey:key];
    }
    [item setObject:obj forKey:sub_key];
  }
  return [self save:item forKey:key];
}

- (BOOL)removeObjectForKey:(NSString*)key withSubKey:(NSString*)sub_key
{
  NSMutableDictionary *item = [data objectForKey:key];
  if (item) {
    if (!sub_key) {
      [item removeAllObjects];
    } else {
      [item removeObjectForKey:sub_key];
    }
  }
  return [self save:item forKey:key];
}
@end
