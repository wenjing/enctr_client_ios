#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "DBConnection.h"
#import "RecordProtocol.h"

@protocol QueryProtocol
@optional
  -(id)       initWithDelegate:(id)delegate0 action:(SEL)action0;
  -(void)     query:(NSDictionary*)params withUpdate:(BOOL)update;
  -(BOOL)     isExists:(sqlite_int64)aId;
  -(NSArray*) getResult;
  -(BOOL)     hasMore;
  -(void)     clear;
@end

@interface QueryBase : NSObject <QueryProtocol>
{
  id delegate;
  SEL action;
  NSMutableArray *results;
  BOOL more;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL action;
@property (nonatomic, retain) NSMutableArray *results;
- (id)recordClass;
@end
