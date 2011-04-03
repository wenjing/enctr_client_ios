#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Statement.h"

@protocol SerializeProtocol
@optional
  - (id) serialize;
  + (id) deserialize:(id)from;
@end

@interface NSObject (Serialize)
- (NSString*) serialize;
+ (id) deserialize:(NSString*)str;
@end

@protocol PersistenceProtocol
@optional
  + (BOOL) isExist:(id)key;
  + (id)   retrieve:(id)key;
  - (BOOL) persist;
  - (BOOL) delete;
@end

@protocol RecordProtocol<PersistenceProtocol>
@optional
  + (NSString*) tableName;
  + (int)       columnCount;
  - (int)       bindStmt:(Statement*)stmt isWithId:(BOOL)with_id;
@end

@interface RecordBase : NSObject <RecordProtocol>
{
  sqlite_uint64 kid;
  sqlite_uint64 odd;
}

@property (nonatomic, assign) sqlite_uint64 kid;
@property (nonatomic, assign) sqlite_uint64 odd;

+ (int)countDB:(NSString*)estmt withOffset:(int)offset withLimit:(int)limit;
+ (NSArray*)queryDB:(NSString*)estmt withOffset:(int)offset withLimit:(int)limit;
+ (BOOL)deleteAllDB:(NSString*)estmt;
+ (BOOL)isExistInDB:(sqlite_uint64)id0;
+ (id)findDB:(sqlite_uint64)id0;

- (id) initWithId:(sqlite_uint64)id0 withOdd:(sqlite_uint64)odd0;
- (id) initWithStmt:(Statement*)stmt;

@end
