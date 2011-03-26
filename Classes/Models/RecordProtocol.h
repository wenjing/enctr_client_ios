#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Statement.h"

@protocol RecordProtocol
@optional
  + (NSString*) tableName;
  + (int)       columnCount;
  - (int)       bindStmt:(Statement*)stmt;
  - (BOOL)      insertDB;
  - (BOOL)      deleteFromDB;
@end

@interface RecordBase : NSObject <RecordProtocol>
{
  sqlite_int64 id;
  sqlite_int64 odd;
}
@property (nonatomic, assign) sqlite_int64 id;
@property (nonatomic, assign) sqlite_int64 odd;
- (id) initWithId:(sqlite_int64)id0 withOdd:(sqlite_int64)odd0;
@end
