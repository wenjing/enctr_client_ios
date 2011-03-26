#import "kaya_meetAppDelegate.h"
#import "QueryProtocol.h"

@implementation QueryBase

@synthesize delegate;
@synthesize action;
@synthesize results;

- (id)initWithTarget:(id)delegate0 action:(SEL)action0 releaseAtCallBack:(BOOL)release0
{
  [super init];
  self.delegate = delegate0;
  self.action = action0;
  releaseAtCallBack = release0;
  meetClient = nil;
  [self clear];
  return self;
}

- (void)dealloc
{
  self.results = nil; 
  if (meetClient) {
    [meetClient cancel];
    [meetClient release];
  }
  [super dealloc];
}

- (void)cancel
{
  if (meetClient != nil ) {
    [meetClient cancel];
    [meetClient release];
    meetClient = nil;
  }
  [self clear];
}

- (BOOL)isExists:(sqlite_int64)aId
{
  static Statement *stmt = nil;
  if (stmt == nil) {
      stmt = [DBConnection statementWithQuery:"SELECT id FROM ? WHERE id=?"];
      [stmt retain];
    }
  [stmt bindString:[[self recordClass] tableName] forIndex:1];
  [stmt bindInt64:aId forIndex:2];
  BOOL result = ([stmt step] == SQLITE_ROW) ? true : false;
  [stmt reset];
  return result;
}

- (NSArray*)getResults
{
  return [self results];
}
- (BOOL)hasMore
{
  return more;
}
- (BOOL)hasError
{
  return error;
}
- (void)clear
{
  self.results = nil;
  self.results = [NSMutableArray array]; // Prepare a empty array
  more = false;
  error = false;
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (id)recordClass
{
  return [RecordBase class];
}

- (void)checkNetworkError:(KYMeetClient*)sender
{
  error = sender.hasError;
  if (error && sender.statusCode == 401) { // authentication fail
    kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openLoginView];
  }
}

- (void)queryDidFinish:(id)obj
{
  [delegate performSelector:action withObject:self withObject:obj];
}

@end
