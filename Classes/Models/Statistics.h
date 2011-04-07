#import <sys/time.h>
#import "RecordProtocol.h"
#import "Singleton.h"

@interface StatBase : NSObject<PersistenceProtocol,SerializeProtocol>
{
  id subKey;
}
@property (nonatomic, retain) id subKey;
+ (NSString*)keyName;
@end

@interface CirkleStat : StatBase
{
  time_t lastQuery;
  time_t latestTime, earliestTime;
}
@property (nonatomic, assign) time_t lastQuery;
@property (nonatomic, assign) time_t latestTime;
@property (nonatomic, assign) time_t earliestTime;
- (id)init;
@end

@interface NewsStat : StatBase
{
  time_t lastQuery;
  time_t latestTime, earliestTime;
  BOOL hasMore; // More to retrieve from server
}
@property (nonatomic, assign) time_t lastQuery;
@property (nonatomic, assign) time_t latestTime;
@property (nonatomic, assign) time_t earliestTime;
@property (nonatomic, assign) BOOL   hasMore;
- (id)init;
@end

@interface MiscStat : StatBase
{
}
- (id)init;
@end

@interface Statistics : RecordBase
{
  NSMutableDictionary *data;
}
@property (nonatomic, retain) NSMutableDictionary *data;

+ (Statistics *)sharedStatistics;
- (id)objectForKey:(NSString*)key withSubKey:(NSString*)sub_key;
- (BOOL)setObject:(id)obj forKey:(NSString*)key withSubKey:(NSString*)sub_key;
- (BOOL)removeObjectForKey:(NSString*)key withSubKey:(NSString*)sub_key;

- (void)clear;
- (void)synchronize;
- (BOOL)load;
- (BOOL)save;
- (BOOL)loadForKey:(NSString*)key;
- (BOOL)save:(id)obj forKey:(NSString*)key;
@end
