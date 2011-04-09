#import "REString.h"
#import "StringUtil.h"
#import "TimeUtils.h"
#import "User.h"
#import "DBConnection.h"
#import "KYMeetClient.h"
#import "CirkleQuery.h"
#import "Statistics.h"

// Usage sample
/*
  // Call
  CirkleQuery *query = [[CirkleQuery alloc] initWithTarget:self action::@selector(cirklesDidLoad:)];
  // Start query with update
  NSMutableDictionary *options = [NSMutableDictionary dictionary];
  [query query:options withUpdate:true];
  // Start query all records w/o update
  [query query:options withUpdate:true];
  // Start query first 100 records
  [options setObject:[NSNumber numberWithInt:100] forKey:@"limit"]
  // Start query next 100 records
  [options setObject:[NSNumber numberWithInt:100+1] forKey:@"offset"]
  // In case to cancel a pending query
  [query cancel];
  // Back
- (void)cirklesDidLoad:(CirkleQuery*)sender
{
  NSArray *results = [sender getResults];
  // Check error
  if ([sender hasError]) ...
  // Check if has more records
  if ([sender hasMore]) ...
  // Use results
  // ...
  // Reset query sender
  [sender clear];
}
*/

@implementation CirkleQuery

+ (id)recordClass
{
  return [Cirkle class];
}

- (void)dealloc 
{
  [super dealloc];
}

// In case of update (sync with remote server), retrieve all updated records from server after
// latest record time. Save (or replace) them to local DB and query the whole records from DB.
// Otherwise, just query and return the whole records from DB.
- (void)query:(NSDictionary*)options withUpdate:(BOOL)update
{
  [self clear];

  self.queryOptions = options;
  self.queryUpdate = update;
  queryStatus = QUERY_STATUS_PENDING;
  queryAction = QUERY_ACTION_LOCAL;
  CirkleStat *stat = [CirkleStat retrieve:nil];
  meetClient = [[KYMeetClient alloc] initWithTarget:self
                                     action:@selector(cirklesDidReceive:obj:)];
  uint32_t user_id = [[NSUserDefaults standardUserDefaults]
                                        integerForKey:@"KYUserId"] ;

  /*if (stat.lastQuery == 0) { // First query, DB must be empty
    update = true;
  }*/
  if (update) {
    queryAction = QUERY_ACTION_UPDATE;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (stat.lastQuery != 0) {
      [param setObject:[NSString dateString:stat.lastQuery-1] forKey:@"after_time"];
    }
    //if (stat.latestTime != 0) { // only get updated recorded after latest timestamp
    //  [param setObject:[NSString dateString:stat.latestTime+1] forKey:@"after_time"];
    //}
    [meetClient getCirkles:param withUserId:user_id];
  } else { // Call callback function directly with empty object.
    KYMeetClient *meet_client = meetClient;
    [self cirklesDidReceive:meetClient obj:[NSArray array]]; 
    [meet_client autorelease];
  }
}

// Combine id and type to form a (BYRD) unique int64 integer as DB id.
static sqlite3_uint64 GetHashId(sqlite3_uint64 id0, const char *type)
{
  NSString *str = [NSString stringWithFormat:@"id=%d type=%s", id0, type];
  return [str md5AsInt64];
}

- (void)cirklesDidReceive:(KYMeetClient*)sender obj:(NSObject*)obj
{
  if (![self isPending]) return; // Ignore cancelled callback
  meetClient = nil; // Do not release here, it will be autorelease inside client
  queryStatus = QUERY_STATUS_OK;
  [self checkNetworkError:sender];
  if ([self hasError] &&
      !obj || ![obj isKindOfClass:[NSArray class]]) {
    queryStatus = QUERY_STATUS_ERROR;
    [self queryDidFinish];
    return;
  }

  CirkleStat *stat = [CirkleStat retrieve:nil];
  if (queryAction == QUERY_ACTION_UPDATE) {
    time_t now; time(&now); stat.lastQuery = now;
  }

  // Process results and save to DB
  [DBConnection beginTransaction];
  NSArray *net_res = (NSArray *)obj; //NSLog(@"%@", net_res);
  int net_count = [net_res count];
  NSEnumerator *iter = [net_res objectEnumerator];
  id item;
  while ((item = [iter nextObject])) {
    // Save each item to DB
    NSDictionary *dic = item;
    sqlite3_uint64 id0 = [[dic objectForKey:@"id"] integerValue];
    NSString *type = [dic objectForKey:@"type"];
    NSString *timestamp = [dic objectForKey:@"timestamp"];
    sqlite3_uint64 hashed_id = GetHashId(id0, [type UTF8String]);
    sqlite3_uint64 odd = [timestamp dateValue]; // odd is purely based on timestamp.
    Cirkle *cirkle = [[Cirkle alloc] initWithData:dic withId:hashed_id withOdd:odd];
    time_t timestamp_val = [timestamp dateValue];
    if (stat.latestTime == 0 || stat.latestTime < timestamp_val) {
      stat.latestTime = timestamp_val;
    }
    if (stat.earliestTime == 0 || stat.earliestTime > timestamp_val) {
      stat.earliestTime = timestamp_val;
    }
    [cirkle persist]; // save to DB
    [cirkle release];
  }

  // Check if having any update (only for update more)
  if (queryAction == QUERY_ACTION_UPDATE && net_count == 0) {
    queryStatus = QUERY_STATUS_NOUPDATE;

  // Only try getting result from DB if there are some updates or
  // it is none-update mode.
  } else {
    // Get from DB
    // It might look quite a waste by a saving/retirve (serialize/deserialize) cycle.
    // It will be more efficient to process and set result right after save to DB operation
    // without retrieving from DB. However, some query might be partial and the order is
    // may not be necessary as exactly what we would like. It will be safer to make the first
    // step to purely sync local DB with remote server. And the actuall query at the 2nd step
    // regardless update is required or not.
    self.results = [NSMutableArray arrayWithCapacity:1024];
    NSArray *res = [Cirkle queryDB:@"" withOffset:0 withLimit:-1]; // full query
    iter = [res objectEnumerator];
    while ((item = [iter nextObject])) {
      Cirkle *cirkle = item;
      id trimmed= [self trimData:cirkle.data];
      if (![trimmed objectForKey:@"is_deleted"]) { // skip deleted cirkles
        [results addObject:trimmed];
      }
    }
  }
  [stat persist]; // update statistics
  [DBConnection commitTransaction];

  [self queryDidFinish];
}

- (id)trimData:(id)obj
{
  id result = obj;
  if ([obj isKindOfClass:[NSArray class]]) {
    result = [NSMutableArray arrayWithCapacity:[obj count]];
    NSEnumerator *iter = [obj objectEnumerator];
    id item;
    while ((item = [iter nextObject])) {
      id trimmed = [self trimData:item];
      [result addObject:trimmed];
    }

  } else if ([obj isKindOfClass:[NSDictionary class]]) {
    result = [NSMutableDictionary dictionary];
    NSEnumerator *iter = [obj keyEnumerator];
    id key;
    while ((key = [iter nextObject])) {
      id item = [obj objectForKey:key];
      id trimmed = nil;
      if ([key isEqualToString:@"user"] ||
          [key isEqualToString:@"inviter"]) {
        User *user = [User userWithJsonDictionary:item];
        //id is_new_user = [item objectForKey:@"is_new_user"];
        //if (!is_new_user) is_new_user = [NSNull null];
        //[DBConnection beginTransaction];
        [user updateDB];
        //[DBConnection commitTransaction];
        trimmed = user;
        //trimmed = [NSMutableArray array];
        //[trimmed addObject:user];
        //[trimmed addObject:is_new_user];
      } else {
        trimmed = [self trimData:item];
      }
      [result setObject:trimmed forKey:key];
    }
  }
  return result;
}

@end
