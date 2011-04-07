#import "REString.h"
#import "StringUtil.h"
#import "TimeUtils.h"
#import "User.h"
#import "DBConnection.h"
#import "KYMeetClient.h"
#import "CirkleQuery.h"
#import "Statistics.h"

@implementation CirkleQuery

//+ (id)recordClass
//{
//  return [Cirkle class];
//}

- (void)dealloc 
{
  [super dealloc];
}

- (void)query:(NSDictionary*)options withUpdate:(BOOL)update
{
  [self clear];

  self.queryOptions = options;
  self.queryUpdate = update;
  queryStatus = QUERY_STATUS_PENDING;
  queryAction = QUERY_ACTION_LOCAL;
  meetClient = [[KYMeetClient alloc] initWithTarget:self
                                     action:@selector(usersDidReceive:obj:)];
  uint32_t user_id = [options integerForKey:@"user_id"] ;
  User *user = [User userWithId];
  if (user) { // Not in local DB
    queryAction = QUERY_ACTION_UPDATE;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [meetClient getUser:param withUserId:user_id];
  } else {
    KYMeetClient *meet_client = meetClient;
    [self usersDidReceive:meetClient obj:user]; 
    [meet_client autorelease];
  }
}

- (void)save:(NSDictionary*)options withObject:(id)obj
{
  [self clear];

  self.queryOptions = options;
  self.queryUpdate = update;
  queryStatus = QUERY_STATUS_PENDING;
  queryAction = QUERY_ACTION_SAVE;
  meetClient = [[KYMeetClient alloc] initWithTarget:self
                                     action:@selector(usersDidSave:obj:)];
  User *user = (User *)obj;
  NSMutableDictionary *param = [NSMutableDictionary dictionary];
  [meetClient postUser:param withUser:user];
}

- (void)usersDidReceive:(KYMeetClient*)sender obj:(NSObject*)obj
{
  if (![self isPending]) return; // Ignore cancelled callback
  meetClient = nil; // Do not release here, it will be autorelease inside client
  queryStatus = QUERY_STATUS_OK;
  [self checkNetworkError:sender];
  if ([self hasError] &&
      !obj || (![obj isKindOfClass:[NSArray class]] &&
               ![obj isKindOfClass:[NSDictionay class]] &&
               ![obj isKindOfClass:[User class]])) {
    queryStatus = QUERY_STATUS_ERROR;
    [self queryDidFinish:nil];
    return;
  }

  if (queryAction == QUERY_ACTION_UPDATE) {
    [DBConnection beginTransaction];
    //NSLog(@"%@", obj);
    NSArray *net_res;
    if ([obj isKindOfClass:[NSArray class]]) {
      net_res = (NSArray *)obj;
    } else {
      net_res = [NSArray arrayWithObject:obj];
    }
    NSEnumerator *iter = [net_res objectEnumerator];
    id item;
    while ((item = [iter nextObject])) {
      // Save each item to DB
      NSDictionary *dic = item;
      User *user = [User userWithJsonDictionary];
      [user updateDB];
      [results addObject:user];
    }
    [DBConnection commitTransaction];
  } else {
    User *user = (User *)obj;
    [results addObject:user];
  }

  [self queryDidFinish:nil];
}

- (void)usersDidSave:(KYMeetClient*)sender obj:(NSObject*)obj
{
  queryAction = QUERY_ACTION_UPDATE;
  [self usersDidReceive:sender obj:obj];
}

@end