#import "kaya_meetAppDelegate.h"
#import "QueryProtocol.h"

@implementation QueryBase

@synthesize delegate;
@synthesize action;
@synthesize results;
@synthesize queryOptions;
@synthesize queryUpdate;

- (id)initWithTarget:(id)delegate0 action:(SEL)action0 releaseAtCallBack:(BOOL)release0
{
  self = [super init];
  if (self != nil) {
    self.delegate = delegate0;
    self.action = action0;
    releaseAtCallBack = release0;
    meetClient = nil;
    [self clear];
  }
  return self;
}

- (void)dealloc
{
  [self clear];
  [super dealloc];
}

- (void)clear
{
  [self cancel];
  self.results = nil;
  self.results = [NSMutableArray array]; // Prepare a empty array
  queryOptions = nil;
  queryUpdate = false;
  queryStatus = QUERY_STATUS_INIT;
  queryAction = QUERY_ACTION_LOCAL;
}

- (void)cancel
{
  if (meetClient != nil ) {
    [meetClient cancel];
    [meetClient autorelease];
    meetClient = nil;
    queryStatus = QUERY_STATUS_INIT;
    queryAction = QUERY_ACTION_LOCAL;
  }
}

- (BOOL)isPending
{
  return queryStatus == QUERY_STATUS_PENDING && meetClient != nil;
}

- (NSArray*)getResults
{
  return [self results];
}
- (BOOL)hasMore
{
  return queryStatus == QUERY_STATUS_MORE;
}
- (BOOL)hasError
{
  return queryStatus == QUERY_STATUS_ERROR;
}
- (BOOL)hasUpdate
{
  return queryStatus != QUERY_STATUS_NOUPDATE;
}
- (int) getStatus
{
  return queryStatus;
}

///////////////////////////////////////////////////////////////////////////////////////////////
+ (id)recordClass
{
  return [RecordBase class];
}

- (void)checkNetworkError:(KYMeetClient*)sender
{
  if (sender.hasError) {
    queryStatus = QUERY_STATUS_ERROR;
  }
  if ([self hasError] && sender.statusCode == 401) { // authentication fail
    kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openLoginView];
  }
}

- (void)queryDidFinish:(id)obj
{
  [delegate performSelector:action withObject:self withObject:obj];
  if (releaseAtCallBack) [self autorelease];
}

@end
