//
//  MeetDataSource.m
//

#import <QuartzCore/QuartzCore.h>
#import "MeetDataSource.h"
#import "kaya_meetAppDelegate.h"
#import "DBConnection.h"
#import "StringUtil.h"

@implementation MeetDataSource

@synthesize meets;
@synthesize contentOffset;
@synthesize showType ;

static NSInteger sortByDate(id a, id b, void *context)
{
    KYMeet* dma = (KYMeet*)a;
    KYMeet* dmb = (KYMeet*)b;
    int diff = dmb.timeAt - dma.timeAt;
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
	[super		dealloc];
}

- (void)removeAllMeets
{
    [meets	removeAllObjects];
}

//
// meets array related functions

- (BOOL) matchMeet:(KYMeet*)mt
{
	if ( mt == nil ) return false ;
	if ( showType == MEET_ALL ) return true ;
	else if ( showType == MEET_SOLO && mt.userCount == 1 ) return true ;
	else if ( showType == MEET_PRIVATE && mt.userCount == 2 ) return true ;
	else if ( showType == MEET_GROUP && mt.userCount > 2 ) return true ;
	return false ;
}

- (int)countMeets
{
	int count = 0 ;
	for( int i = 0 ; i < [meets count]; i ++ ) 
		if ( [self matchMeet:[meets objectAtIndex:i]] ) count ++ ;
    return count  ;
}

- (int)cvtIndex:(int)i
{
	if ( showType == MEET_ALL ) return i ;
	for( int ct = 0 ; ct < [meets count] ; ct ++ ){
		if ( [self matchMeet:[meets objectAtIndex:ct]] ) {
			if ( i == 0 ) return ct ;
			else i-- ;
		}
	}
	return i ; // ?? over flow
}

- (KYMeet*)meetAtIndex:(int)i
{
	if (i >= [self countMeets]) return NULL;
	int j = [self cvtIndex:i] ;
    if (j >= [meets count]) return NULL;
    return [meets objectAtIndex:j]   ;
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
	int j = [self cvtIndex:index] ;
    [meets removeObjectAtIndex:j] ;
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
	int j = [self cvtIndex:index] ;
	//int j = index ;
    [meets insertObject:meet atIndex:j];
}

- (int)indexOfObject:(KYMeet*)meet
{
    for (int i = 0; i < [meets count]; ++i) {
        KYMeet* sts = [meets objectAtIndex:i];
        if (sts.meetId == meet.meetId) {
			return [self cvtIndex:i];
        }
    }
    return -1;
}


// restore Meets from DB
// 
- (int)restoreMeets:(MeetType)aType all:(BOOL)all
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        static char *sql = "SELECT * FROM meets WHERE meets.type = ? ORDER BY id DESC LIMIT ? OFFSET ?";
        stmt = [DBConnection statementWithQuery:sql];
        [stmt retain];
    }
    
    [stmt bindInt32:aType			 forIndex:1];
    [stmt bindInt32:all?1000:KAYAMEET_MAX_LOAD       forIndex:2];
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
