#import "REString.h"
#import "StringUtil.h"
#import "TimeUtils.h"
#import "User.h"
#import "NewsQuery.h"
#import "Statistics.h"

@implementation NewsQuery

+ (id)recordClass
{
  return [News class];
}

- (void)dealloc 
{
  [super dealloc];
}

static NSString *GetStmt(uint64_t friend_id, uint64_t cirkle_id)
{
  NSString *stmt = nil;
  stmt= [NSString stringWithFormat:@"WHERE (uid = %qu AND cid = %qu)", friend_id, cirkle_id];
  return stmt;
}

// options: offset, limit
- (void)query:(NSDictionary*)options withUpdate:(BOOL)update
{
  [self clear];

  self.queryOptions = options;
  self.queryUpdate = update;
  queryStatus = QUERY_STATUS_PENDING;
  queryAction = QUERY_ACTION_LOCAL;
  meetClient = [[KYMeetClient alloc] initWithTarget:self
                                     action:@selector(newsDidReceive:obj:)];
  uint64_t user_id = [[NSUserDefaults standardUserDefaults]
                                        integerForKey:@"KYUserId"] ;
  NSNumber *friend_id = [options objectForKey:@"friend_id"];
  NSNumber *cirkle_id = [options objectForKey:@"cirkle_id"];
  NSNumber *offset = [options objectForKey:@"offset"];
  NSNumber *limit = [options objectForKey:@"limit"];
  uint64_t friend_id_val = 0, cirkle_id_val = 0;
  if (friend_id) {
    friend_id_val = [friend_id longLongValue];
  } else if (cirkle_id) {
    cirkle_id_val = [cirkle_id longLongValue];
  }

  NSString *stat_key = [NSString stringWithFormat:@"uid=%qu:cid=%qu",
                                    friend_id_val, cirkle_id_val];
  NewsStat *stat = [NewsStat retrieve:stat_key];
  //if (stat.lastQuery == 0) { // First query, auto load from server
  //  update = true;
  //}
  NSMutableDictionary *param = nil;
  if (!update) {
    if (stat.lastQuery != 0 && stat.hasMore) {
      // Do not try loading from server if this is the first time query. A subsequent
      // update mode query shall follow anyway.
      // Do not try retrieving more if we know there ain't anymore.
      int retrieve_more = 0;
      if (limit) { // check if local DB has enough records
        int limit_val = [limit integerValue];
        int offset_val = offset ? [offset integerValue] : 0;
        NSString *stmt = GetStmt(friend_id_val, cirkle_id_val);
        int count = [News countDB:stmt withOffset:0 withLimit:limit_val];
        retrieve_more = limit_val+offset_val+1 - count;
      }
      if (retrieve_more > 0 || !limit) { // not enough, try getting more from remote server
        queryAction = QUERY_ACTION_RETRIEVE;
        param = [NSMutableDictionary dictionary];
        // earliestTime must exist
        if (stat.earliestTime != 0) {
          [param setObject:[NSString dateString:stat.earliestTime-1] forKey:@"before_time"];
        }
        if (limit) {
          [param setObject:[NSString stringWithFormat:@"%d", retrieve_more] forKey:@"limit"];
        }
      }
    }
  } else {
    queryAction = QUERY_ACTION_UPDATE;
    param = [NSMutableDictionary dictionary];
    if (stat.latestTime != 0) { // only get updated recorded after latest timestamp
      [param setObject:[NSString dateString:stat.latestTime+1] forKey:@"after_time"];
    }
    //if (offset) {
    //  [param setObject:[NSString stringWithFormat:@"%d", offset_val] forKey:@"offset"];
    //}
    if (limit) {
      // Get one more so we can tell if there more to come
      int limit_val = [limit integerValue];
      int offset_val = offset ? [offset integerValue] : 0;
      [param setObject:[NSString stringWithFormat:@"%d", limit_val+offset_val+1] forKey:@"limit"];
    }
  }

  if (param) { // get from remote server
    if (friend_id) {
      [meetClient getNews:param withUserId:user_id withFriendId:friend_id_val];
    } else if (cirkle_id) {
      [meetClient getNews:param withUserId:user_id withCirkleId:cirkle_id_val];
    } else {
      [meetClient getNews:param withUserId:user_id];
    }
  } else { // call callback function directly with empty object.
    KYMeetClient *meet_client = meetClient;
    [self newsDidReceive:meetClient obj:[NSArray array]];
    [meet_client autorelease];
  } 
}

static sqlite3_uint64 GetHashId(sqlite3_uint64 id0, uint64_t friend_id, uint64_t cirkle_id,
                                const char *type, const char *timestamp)
{
//NSString *str = [NSString stringWithFormat:@"id=%qu friend_id=%qu cirkle_id=%qu type=%s timestamp=%s",
//                                           id0, friend_id, cirkle_id, type, timestamp];
// Ignore timestamp, overwrite existing record
  NSString *str = [NSString stringWithFormat:@"id=%qu friend_id=%qu cirkle_id=%qu type=%s",
                                             id0, friend_id, cirkle_id, type];
  return [str md5AsInt64];
}

- (void)newsDidReceive:(KYMeetClient*)sender obj:(NSObject*)obj
{
  //NSLog(@"%@", obj);
  if (![self isPending]) return; // Ignore cancelled callback
  meetClient = nil; // Do not release here, it will be autorelease inside client
  queryStatus = QUERY_STATUS_OK;
  [self checkNetworkError:sender];
  if ([self hasError] &&
      !obj || ![obj isKindOfClass:[NSArray class]]) {
    queryStatus = QUERY_STATUS_ERROR;
    [self queryDidFinish:nil];
    return;
  }

  NSNumber *friend_id = [queryOptions objectForKey:@"friend_id"];
  NSNumber *cirkle_id = [queryOptions objectForKey:@"cirkle_id"];
  NSNumber *offset = [queryOptions objectForKey:@"offset"];
  NSNumber *limit = [queryOptions objectForKey:@"limit"];
  uint64_t friend_id_val = 0, cirkle_id_val = 0;
  if (friend_id) {
    friend_id_val = [friend_id longLongValue];
  } else if (cirkle_id) {
    cirkle_id_val = [cirkle_id longLongValue];
  }
  int offset_val = offset ? [offset integerValue] : 0;
  int limit_val = limit ? [limit integerValue] : -1;
  int limit_valx = limit_val > 0 ? limit_val+1 : -1;
  NSString *filter_type = [queryOptions objectForKey:@"filter_type"];
  NSNumber *filter_id = [queryOptions objectForKey:@"filter_id"];
  uint64_t filter_id_val = 0;
  if (filter_type && filter_id && queryAction == QUERY_ACTION_UPDATE) {
    filter_id_val = [filter_id integerValue];
  }

  NSString *stmt = GetStmt(friend_id_val, cirkle_id_val);
  NSString *stat_key = [NSString stringWithFormat:@"uid=%qu:cid=%qu",
                                    friend_id_val, cirkle_id_val];
  NewsStat *stat = nil;
  if (filter_id_val == 0) {
    stat = [NewsStat retrieve:stat_key];
  } else { // Do not update stat for filter mode, create a dummy one
    stat = [[[NewsStat alloc] init] autorelease];
  }
  BOOL was_empty = stat.lastQuery == 0;
  if (queryAction == QUERY_ACTION_RETRIEVE ||
      queryAction == QUERY_ACTION_UPDATE) { // Do not record pure local query
    time_t now; time(&now); stat.lastQuery = now;
  }

  [DBConnection beginTransaction];
  NSArray *net_res = (NSArray *)obj; //NSLog(@"%@", net_res);
  int net_count = [net_res count];

  // This will leave a hole in DB and in table model data. To keep integrity,
  // remove all old records.
  if (queryAction == QUERY_ACTION_UPDATE) {
    if (filter_id_val == 0 &&
        limit_val > 0 && net_count > limit_val+offset_val) {
      [News deleteAllDB:stmt];
      stat.latestTime = stat.earliestTime = 0;
      stat.hasMore = true; // not sure any more
    }
    // Do not return more than number of new records.
    // Like Cirkles, in update mode, return all or nothing
    //if (limit_val < 0 || limit_val+offset_val >= net_count) {
    //  limit_valx = limit_val = net_count-offset_val;
    //}
  }

  // Process results and save to DB
  NSEnumerator *iter = [net_res objectEnumerator];
  id item;
  while ((item = [iter nextObject])) {
    // Save each item to DB
    NSDictionary *dic = item;
    sqlite3_uint64 id0 = [[dic objectForKey:@"id"] integerValue];
    NSString *type = [dic objectForKey:@"type"];
    if (filter_id_val != 0 &&
        !(filter_id_val == id0 && [filter_type isEqualToString:type])) {
      continue; // skip this one
    }
    NSString * timestamp = [dic objectForKey:@"timestamp"];
    sqlite3_uint64 hashed_id = GetHashId(id0, friend_id_val, cirkle_id_val,
                                         [type UTF8String], [timestamp UTF8String]);
    sqlite3_uint64 odd = [timestamp dateValue]; // odd is purely based on timestamp.
    sqlite3_uint64 uid = friend_id_val, cid = cirkle_id_val;
    News *news = [[News alloc] initWithData:dic withId:hashed_id withOdd:odd
                                                withUserId:uid withCirkleId:cid];
    time_t timestamp_val = [timestamp dateValue];
    if (stat.latestTime == 0 || stat.latestTime < timestamp_val) {
      stat.latestTime = timestamp_val;
    }
    if (stat.earliestTime == 0 || stat.earliestTime > timestamp_val) {
      stat.earliestTime = timestamp_val;
    }
    [news persist]; // save to DB
    if (filter_id_val != 0) {
      id trimmed= [self trimData:news.data];
      [results addObject:trimmed];
    }
    [news release];
  }

  // Check if having any update (only for update more)
  if (queryAction == QUERY_ACTION_UPDATE && net_count == 0) {
    queryStatus = QUERY_STATUS_NOUPDATE;

  // Only try getting result from DB if there are some updates or
  // it is none-update mode.
  } else if (filter_id_val == 0) { // Filter mode has already processed results
    NSMutableArray *db_res = (NSMutableArray *)[News queryDB:stmt withOffset:offset_val 
                                                                  withLimit:limit_valx];
    self.results = [NSMutableArray arrayWithCapacity:
                                      ((limit_val>0&&limit_val<1024)?limit_val:1024)];
    iter = [db_res objectEnumerator];
    while ((item = [iter nextObject])) {
      if (limit_val > 0 && [results count] >= limit_val) {
        // There are more to come, but do not add to results
        queryStatus = QUERY_STATUS_MORE;
        break;
      }
      News *news = item;
      id trimmed= [self trimData:news.data];
      [results addObject:trimmed];
    }
  }
  // Check if has retrieved all records from remote server or not
  if (![self hasMore] &&
      (queryAction == QUERY_ACTION_RETRIEVE ||
       queryAction == QUERY_ACTION_UPDATE && was_empty)) {
    // Tried retrieve however get less than requested, there must be
    // no more older records in remote server left not retrieved.
    stat.hasMore = false;
  }

  if (filter_id_val == 0) { // update statistics, but only when not at filter mode
    [stat persist];
  }
  [DBConnection commitTransaction];

  [self queryDidFinish:nil];
}

- (id)trimData:(id)obj
{
  id result = obj;
  if ([obj isKindOfClass:[NSArray class]]) {
    result = [NSMutableArray array];
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
      if (item != [NSNull null] &&
          ([key isEqualToString:@"user"] || 
           [key isEqualToString:@"marked_user"])) {
        key = @"user";
        User *user = [User userWithJsonDictionary:item];
        id is_new_user = [item objectForKey:@"is_new_user"];
        if (!is_new_user) is_new_user = @"0";
        //[DBConnection beginTransaction];
        [user updateDB] ;
        //[DBConnection commitTransaction];
        trimmed = [NSMutableArray array];
        [trimmed addObject:user];
        [trimmed addObject:is_new_user];
      } else if ([key isEqualToString:@"marked_name"]) {
        key = @"name";
        trimmed = [self trimData:item];
      } else if ([key isEqualToString:@"marked_top_chatters"] ||
                 [key isEqualToString:@"marked_chatters"]) {
        key = [key isEqualToString:@"marked_top_chatters"] ? @"top_chatters" : @"chatters";
        NSArray *chatters = [self trimData:item];
        trimmed = [NSMutableArray array];
        for (int nn = 0; nn < [chatters count]; ++nn) {
          NSDictionary *chatter = [chatters objectAtIndex:nn];
          [trimmed addObject:[chatter objectForKey:@"chatter"]];
        }
      } else if ([key isEqualToString:@"marked_top_users"] ||
                 [key isEqualToString:@"marked_users"]) {
        key = [key isEqualToString:@"marked_top_users"] ? @"top_users" : @"users";
        NSArray *users = [self trimData:item];
        trimmed = [NSMutableArray array];
        for (int nn = 0; nn < [users count]; ++nn) {
          NSDictionary *chatter = [users objectAtIndex:nn];
          [trimmed addObject:[chatter objectForKey:@"user"]];
        }
      } else {
        trimmed = [self trimData:item];
      }
      [result setObject:trimmed forKey:key];
    }
  }
  return result;
}

@end
