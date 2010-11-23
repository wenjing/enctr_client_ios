
// KYMeet.m
//
//
#import "KYMeet.h"
#import "DBConnection.h"
#import "REString.h"
#import "StringUtil.h"
#import "TimeUtils.h"

@interface KYMeet (Private)
- (void)insertDB;
@end

// sort function of DM timeline
//
static NSInteger sortByDateDesc(id a, id b, void *context)
{
    KYMeet* dma = (KYMeet*)a;
    KYMeet* dmb = (KYMeet*)b;
    int diff = dmb.timeAt - dma.timeAt;
    if (diff > 0)
        return -1;
    else if (diff < 0)
        return 1;
    else
        return 0;
}

@implementation KYMeet

@synthesize source;
@synthesize user;

- (void)dealloc
{
	[meetUsers release];
	[source release];
  	[super dealloc];
}

- (void)updateWithJsonDictionary:(NSDictionary*)dic 
{
	struct tm created;
    time_t now;
    time(&now);	
	
    type			 = [[dic objectForKey:@"type"]   longValue];
	meetId           = [[dic objectForKey:@"id"]     longLongValue];
	postId			 = [[dic objectForKey:@"postid"] longLongValue];
	longitude        = [[dic objectForKey:@"lng"]    floatValue] ;
	latitude         = [[dic objectForKey:@"lat"]    floatValue] ;
	userCount		 = [[dic objectForKey:@"users_count"] longValue];
    
	//
	// Check userCount value, create meetUsers array
	//
	meetUsers =[[NSMutableArray array] retain];
	// loop to add users, DBupdate
	
	NSString* stringOftime = [dic objectForKey:@"time"] ;
    if ( stringOftime ) {
		strptime([stringOftime UTF8String], "%FT%T%z",  &created) ;
		timeAt = timegm(&created);
	}
		
	// need server response meet names by string "description" in a format as "@name @name @name #place"
    NSString *textString = [dic objectForKey:@"city"] ;
	NSString *zipString  = [dic objectForKey:@"zip" ] ;
	
    if (textString == nil || (id)textString == [NSNull null]) {
        description = @"";
    }
    else {
        description = [[NSString stringWithFormat:@" at %@ - %@", textString, zipString] retain];
    }
	
	// can add more info by source, html links
    // parse source parameter
    NSString *src = [dic objectForKey:@"source"];
    if (src == nil || (id)src == [NSNull null]) {
        source = @"";
    }
    else {
		[source release];
        NSRange r = [src rangeOfString:@"<a href"];
        if (r.location != NSNotFound) {
            NSRange start = [src rangeOfString:@"\">"];
            NSRange end   = [src rangeOfString:@"</a>"];
            if (start.location != NSNotFound && end.location != NSNotFound) {
                r.location = start.location + start.length;
                r.length = end.location - r.location;
                source = [[src substringWithRange:r] retain];
            }
        }
        else {
            source = [src retain];
        }
    }

}

- (id)initWithJsonDictionary:(NSDictionary*)dic type:(MeetType)aType user:(User*)aUser
{
	self = [super init];
    [self updateWithJsonDictionary:dic];
    type = aType;
	
	// if we will post Friends' meets in the future
	// there will be user: 
	user = aUser ;
	return self;
}

- (id)initWithJsonDictionary:(NSDictionary*)dic type:(MeetType)aType
{
	User *aUser = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
	return [self initWithJsonDictionary:dic type:aType user:aUser] ;
}

- (id)initWithJsonDictionary:(NSDictionary*)dic
{
	User *aUser = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId"]];
	return [self initWithJsonDictionary:dic type:KYMEET_TYPE_SENT user:aUser] ;
}

+ (KYMeet*)meetWithJsonDictionary:(NSDictionary*)dic type:(MeetType)type
{
	return [[[KYMeet alloc] initWithJsonDictionary:dic type:type] autorelease];
}


int sTextWidth[] = {
    CELL_WIDTH,
    USER_CELL_WIDTH,
    DETAIL_CELL_WIDTH,
};

- (void)updateAttribute
{
    [super updateAttribute];
    int textWidth = sTextWidth[type];

    if (accessoryType == UITableViewCellAccessoryDetailDisclosureButton) {
        textWidth -= DETAIL_BUTTON_WIDTH;
    }
    else if (type == KYMEET_TYPE_UPDATE) {
        textWidth -= H_MARGIN;
    }
    else {
        textWidth -= INDICATOR_WIDTH;
    }
    // Calculate text bounds and cell height here
    //
    [self calcTextBounds:textWidth];
}

+ (KYMeet*)meetWithId:(sqlite_int64)aMeetId
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT * FROM meets WHERE id = ?"];
        [stmt retain];
    }

    [stmt bindInt32:aMeetId forIndex:1];
    if ([stmt step] != SQLITE_ROW) {
        [stmt reset];
        return nil;
    }
    
    KYMeet *s = [KYMeet initWithStatement:stmt ];
    [stmt reset];
    return s;
}


// In the assumption that user DB will also exist!
//
//
+ (KYMeet*)initWithStatement:(Statement*)stmt
{
    // sqlite3 statement should be:
    //  SELECT * FROM messsages
    //
    KYMeet *s               = [[[KYMeet alloc] init] autorelease];
    
    s.meetId                = [stmt getInt64:0];
	s.postId				= [stmt getInt64:1];
	uint32_t uid			= [stmt getInt32:2];
	s.user = [User userWithId:uid] ;
	s.type =				  [stmt getInt32:3];
	s.timeAt                = [stmt getInt32:4];
    s.longitude             = [[stmt getString:5] floatValue];
    s.latitude              = [[stmt getString:6] floatValue];
    s.description           = [stmt getString:7] ;
    s.source                = [stmt getString:8] ;
	s.userCount				= [stmt getInt32:9] ;
			  
	if (s.user == nil) {
		NSLog(@"KYMeet initial with stm error");
        return nil;
    }
    [s updateAttribute];
    return s;
}

+ (BOOL)isExists:(sqlite_int64)aMeetId
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT id FROM meets WHERE id=?"];
        [stmt retain];
    }
    
    [stmt bindInt64:aMeetId forIndex:1];
    BOOL result = ([stmt step] == SQLITE_ROW) ? true : false;
    [stmt reset];
    return result;
}


// get meets array by the userId
// currently only support self meets
// can add different userId meets array
//

- (int)getMeetsFromDB:(NSMutableArray*)meets
{
    NSMutableDictionary *hash = [NSMutableDictionary dictionary];    
    int count = 1;
    [meets   addObject:self];
    [hash    setObject:self forKey:[NSString stringWithFormat:@"%lld", self.user.userId]];
    
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM meets WHERE userId IN (%@)", self.user.userId];
	Statement *stmt = [DBConnection statementWithQuery:[sql UTF8String]];
        
	//NSLog(@"Exec %@", sql);
	while ([stmt step] == SQLITE_ROW) {
		NSString *idStr = [NSString stringWithFormat:@"%lld", [stmt getInt64:0]];
		//NSLog(@"Found %@", idStr);
		if (![hash objectForKey:idStr]) {
			KYMeet *s = [KYMeet initWithStatement:stmt];
			[hash setObject:s forKey:idStr];
			[meets addObject:s];
			// Up to 20 meets
			if (++count >= 20) break;
		}
	}
	[stmt reset];
    [meets sortUsingFunction:sortByDateDesc context:nil];    
    return count;
}

- (void)insertDB
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO meets VALUES(?, ?,  ?, ?, ?, ?, ?, ?, ?, ?)"];
        [stmt retain];
    }
    [stmt bindInt64:meetId			forIndex:1];
	[stmt bindInt64:postId		forIndex:2];
	[stmt bindInt32:user.userId forIndex:3];
	[stmt bindInt32:type        forIndex:4];
	[stmt bindInt32:timeAt        forIndex:5];
	[stmt bindString:[NSString stringWithFormat:@"%lf", longitude] forIndex:6];
	[stmt bindString:[NSString stringWithFormat:@"%lf", latitude]  forIndex:7];
    [stmt bindString:description forIndex:8];
    [stmt bindString:source     forIndex:9];
	[stmt bindInt32:userCount   forIndex:10];

    if ([stmt step] != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
// will add user in the future
//    [user updateDB];
}

- (void)deleteFromDB
{
    Statement *stmt = [DBConnection statementWithQuery:"DELETE FROM meets WHERE id = ?"];
    [stmt bindInt64:meetId forIndex:1];
    [stmt step]; // ignore error
}

@end
