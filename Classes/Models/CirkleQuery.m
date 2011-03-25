#import "REString.h"
#import "StringUtil.h"
#import "TimeUtils.h"
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

// params: offset, limit, before_time, after_time
- (void)query:(NSDictionary*)params withUpdate:(BOOL)update
{
}

@end
