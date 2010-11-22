//
//  MeetDataSource.m
//

#import <QuartzCore/QuartzCore.h>
#import "MeetDataSource.h"
#import "kaya_meetAppDelegate.h"
#import "DBConnection.h"

@implementation MeetDataSource

@synthesize meets;
@synthesize contentOffset;

static NSInteger sortByDate(id a, id b, void *context)
{
    KYMeet* dma = (KYMeet*)a;
    KYMeet* dmb = (KYMeet*)b;
    int diff = dmb.createdAt - dma.createdAt;
    if (diff > 0)
        return 1;
    else if (diff < 0)
        return -1;
    else
        return 0;
}

- (id)init
{
    [super init];
     loadCell   = [[LoadCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"LoadCell"];
     meets   =    [[NSMutableArray array] retain];
     return self;
}

- (void)dealloc {
    [loadCell   release];
    [meets		release];
	[super dealloc];
}

- (void)removeAllMeets
{
    [meets	removeAllObjects];
}


//
// meets array related functions

- (int)countMeets
{
    return [meets count];
}

- (KYMeet*)meetAtIndex:(int)i
{
    if (i >= [meets count]) return NULL;
    return [meets objectAtIndex:i];
}

-(KYMeet*)meetById:(sqlite_int64)meetId
{
    for (int i = 0; i < [meets count]; ++i) {
        KYMeet* sts = [meets objectAtIndex:i];
        if (sts.meetId == meetId) {
            return sts;
        }
    }
    return nil;
}

- (KYMeet*)lastMeet
{
    return [meets lastObject];
}

- (void)removeMeetAtIndex:(int)index
{
    [meets removeObjectAtIndex:index];
}

- (void)removeMeet:(KYMeet*)meet
{
    for (int i = 0; i < [meets count]; ++i) {
        KYMeet* sts = [meets objectAtIndex:i];
        if (sts.meetId == meet.meetId) {
            [meets removeObjectAtIndex:i];
            return;
        }
    }
}

- (void)removeLastMeet
{
    [meets removeLastObject];
}

- (void)sortByDate
{
    [meets sortUsingFunction:sortByDate context:nil];    
}

- (void)appendMeet:(KYMeet*)meet
{
    [meets addObject:meet];
}

- (void)insertMeet:(KYMeet*)meet atIndex:(int)index
{
    [meets insertObject:meet atIndex:index];
}

- (int)indexOfObject:(KYMeet*)meet
{
    for (int i = 0; i < [meets count]; ++i) {
        KYMeet* sts = [meets objectAtIndex:i];
        if (sts.meetId == meet.meetId) {
            return i;
        }
    }
    return -1;
}


// restore Meets from DB
- (int)restoreMeets:(MeetType)aType all:(BOOL)all
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        static char *sql = "SELECT * FROM meets WHERE meets.type = ? ORDER BY id DESC LIMIT ? OFFSET ?";
        stmt = [DBConnection statementWithQuery:sql];
        [stmt retain];
    }
    
    [stmt bindInt32:aType            forIndex:2];
    [stmt bindInt32:(all) ? 20 : 10  forIndex:2];
    [stmt bindInt32:[meets count]    forIndex:3];
	
    int count = 0;
    while ([stmt step] == SQLITE_ROW) {
        KYMeet* sts = [KYMeet initWithStatement:stmt];
        if (sts) {
            [meets addObject:sts];
            ++count;
        }
    }
    [stmt reset];
    return count;
}



@end
