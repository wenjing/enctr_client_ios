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
  -(BOOL)     isExists:(sqlite_int64)aId;
  -(NSArray*) getResults;
  -(BOOL)     hasMore;
  -(BOOL)     hasError;
  -(void)     clear;
@end

@interface QueryBase : NSObject <QueryProtocol>
{
  id delegate;
  SEL action;
  BOOL releaseAtCallBack;
  NSMutableArray *results;
  KYMeetClient *meetClient;
  BOOL error;
  BOOL more;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL action;
@property (nonatomic, retain) NSMutableArray *results;
- (id)recordClass;
- (void)checkNetworkError:(KYMeetClient*)sender;
- (void)queryDidFinish:(id)obj;
@end
