#import "REString.h"
#import "StringUtil.h"
#import "TimeUtils.h"
#import "User.h"
#import "NewsQuery.h"

@implementation NewsQuery

- (id)recordClass
{
  return [News class];
}

- (void)dealloc 
{
  [super dealloc];
}

// options: offset, limit, before_time, after_time
- (void)query:(NSDictionary*)options withUpdate:(BOOL)update
{
  [self cancel];
  meetClient = [[KYMeetClient alloc] initWithTarget:self action:@selector(newsDidReceive:obj:)];
  uint32_t user_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId"] ;
  NSNumber *friend_id = [options objectForKey:@"friend_id"];
  NSNumber *cirkle_id = [options objectForKey:@"cirkle_id"];
  NSMutableDictionary *param = [NSMutableDictionary dictionary];
  //int offset = 0;
  int limit = 100;
  [param setObject:[NSString stringWithFormat:@"%d", limit] forKey:@"limit" ];
  if (friend_id) {
    [meetClient getNews:param withUserId:user_id withFriendId:[friend_id intValue]];
  } else if (cirkle_id) {
    [meetClient getNews:param withUserId:user_id withCirkleId:[cirkle_id intValue]];
  } else {
    [meetClient getNews:param withUserId:user_id];
  }
}

- (void)newsDidReceive:(KYMeetClient*)sender obj:(NSObject*)obj
{
  meetClient = nil;
  more = true;
  [self checkNetworkError:sender];
  if (error) return;
  if (!obj) return;
  if (![obj isKindOfClass:[NSArray class]]) return;
  
  NSArray *array = (NSArray *)obj;
  //NSLog(@"%@", array);
  NSEnumerator *iter = [array objectEnumerator];
  id item;
  while ((item = [iter nextObject])) {
    id trimmed= [self trimData:item];
    [results addObject:trimmed];
  }
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
        [DBConnection beginTransaction];
        [user updateDB] ;
        [DBConnection commitTransaction];
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

//+ (KYNews*)timelineWithStatement:(Statement*)stmt
//{
//  id = [stmt getInt64:0];
//  data = [stmt getString:1]
//  KYNews *s = [[[KYNews alloc] initWithData:data withId:id] autorelease];
//  NSDictionary *dic = [[stmt getString:1] JSONValue]
//  KYNews *s = [s initWithJsonDictionary:dic]
//  s.data = nil; // Done, no longer useful
//  if (s.timestamp == nil) {
//    NSLog(@"KYNews initial with stm error");
//    return nil;
//  }
//  return s;
//}
//
//+ (int)getNewssFromDB:(NSMutableArray*)timelines
//{
//  User *user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
//  int count = 0;
//    
//  NSString *sql = [NSString stringWithFormat:@"SELECT * FROM timelines WHERE userId IN (%d)", user.userId];
//  Statement *stmt = [DBConnection statementWithQuery:[sql UTF8String]];
//        
//  while ([stmt step] == SQLITE_ROW) {
//    KYNews *s = [KYNews timelineWithStatement:stmt];
//    [timelines addObject:s];
//  }
//  [stmt reset];
//  return count;
//}

@end
