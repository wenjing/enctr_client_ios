#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "DBConnection.h"
#import "KYMeetClient.h"
#import "RecordProtocol.h"

@protocol QueryProtocol
@optional
  -(id)       initWithTarget:(id)delegate0 action:(SEL)action0 releaseAtCallBack:(BOOL)release0;
  -(void)     query:(NSDictionary*)options withUpdate:(BOOL)update;
  -(void)     cancel;
  -(BOOL)     isCancelled;
  -(NSArray*) getResults;
  -(int)      getStatus;
  -(void)     clear;
  -(BOOL)     hasMore;
  -(BOOL)     hasError;
  -(BOOL)     hasUpdate;
  -(BOOL)     isPending;
@end

enum {QUERY_ACTION_LOCAL, QUERY_ACTION_UPDATE, QUERY_ACTION_RETRIEVE};
enum {QUERY_STATUS_INIT, QUERY_STATUS_PENDING, QUERY_STATUS_OK,
      QUERY_STATUS_MORE, QUERY_STATUS_NOUPDATE, QUERY_STATUS_ERROR};
@interface QueryBase : NSObject <QueryProtocol>
{
  id delegate;
  SEL action;
  BOOL releaseAtCallBack;
  NSMutableArray *results;
  KYMeetClient *meetClient;
  NSDictionary *queryOptions;
  int queryStatus;
  int queryAction;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL action;
@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSDictionary *queryOptions;
+ (id)recordClass;
- (void)checkNetworkError:(KYMeetClient*)sender;
- (void)queryDidFinish:(id)obj;
@end
