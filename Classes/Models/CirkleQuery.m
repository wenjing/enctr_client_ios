#import "REString.h"
#import "StringUtil.h"
#import "TimeUtils.h"
#import "User.h"
#import "DBConnection.h"
#import "KYMeetClient.h"
#import "CirkleQuery.h"

@implementation CirkleQuery

- (id)recordClass
{
  return [Cirkle class];
}

- (void)dealloc 
{
  [super dealloc];
}

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

// params: offset, limit, before_time, after_time
- (void)query:(NSDictionary*)options withUpdate:(BOOL)update
{
  [self cancel];
  meetClient = [[KYMeetClient alloc] initWithTarget:self action:@selector(cirklesDidReceive:obj:)];
  uint32_t user_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId"] ;
  //NSNumber *friend_id = [options objectForKey:@"friend_id"];
  //NSNumber *cirkle_id = [options objectForKey:@"cirkle_id"];
  NSMutableDictionary *param = [NSMutableDictionary dictionary];
  //offset = 0;
  //limit = 10;
  //[param setObject:[NSString stringWithFormat:@"%d", limit] forKey:@"limit" ];
  //if (friend_id) {
  //  [meetClient getCirkles:param withUserId:user_id withFriendId:[friend_id intValue]];
  //} else if (cirkle_id) {
  //  [meetClient getCirkles:param withUserId:user_id withCirkleId:[cirkle_id intValue]];
  //} else {
    [meetClient getCirkles:param withUserId:user_id];
  //}
}

- (void)cirklesDidReceive:(KYMeetClient*)sender obj:(NSObject*)obj
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
      if ([key isEqualToString:@"user"]) {
        User *user = [User userWithJsonDictionary:item];
        //id is_new_user = [item objectForKey:@"is_new_user"];
        //if (!is_new_user) is_new_user = [NSNull null];
        [DBConnection beginTransaction];
        [user updateDB] ;
        [DBConnection commitTransaction];
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
