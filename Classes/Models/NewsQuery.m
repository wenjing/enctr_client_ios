#import "REString.h"
#import "StringUtil.h"
#import "TimeUtils.h"
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

// params: offset, limit, before_time, after_time
- (void)query:(NSDictionary*)params withUpdate:(BOOL)update
{
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
