
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
@synthesize user, place, latestChat;

- (void)dealloc
{
	[meetUsers release];
	[source release];
	[place release];
	[latestChat release];
  	[super dealloc];
}

- (void)updateWithJsonDictionary:(NSDictionary*)dic 
{
	struct tm created;
    time_t now;
    time(&now);	
	
    //type			 = [[dic objectForKey:@"type"]   longValue];
	meetId           = [[dic objectForKey:@"id"]     longLongValue];
	postId			 = [[dic objectForKey:@"postid"] longLongValue];
	longitude        = [[dic objectForKey:@"lng"]    floatValue] ;
	latitude         = [[dic objectForKey:@"lat"]    floatValue] ;
	userCount		 = [[dic objectForKey:@"users_count"] longValue];
	
	NSString* stringOftime = [dic objectForKey:@"time"] ;
    if ( stringOftime ) {
		strptime([stringOftime UTF8String], "%FT%T%z",  &created) ;
		timeAt   = timegm(&created);
	}
	stringOftime = [dic objectForKey:@"updated_at"] ;
    if ( stringOftime ) {
		strptime([stringOftime UTF8String], "%FT%T%z",  &created) ;
		updateAt = timegm(&created);
	}		
	
	//
	// Check userCount value, create meetUsers array
	//

	// loop to add users, DBupdate
	NSArray *ary = (NSArray *)[dic objectForKey:@"users"];
	NSArray *chatters = (NSArray *)[dic objectForKey:@"topics"];
	if ( [ary isKindOfClass:[NSArray class]] ) {
		if (place != nil)  [place release];
		if (latestChat != nil) [latestChat release];
		if (meetUsers != nil) [meetUsers release] ;
		place = [[dic objectForKey:@"location"] retain];
		meetUsers =[[NSMutableArray array] retain];
		userCount = [ary count] ;
		[DBConnection beginTransaction];
		for (int i = 0 ; i < [ary count] ; i ++) {
			NSDictionary *dic = (NSDictionary*)[ary objectAtIndex:i] ;
			if (![dic isKindOfClass:[NSDictionary class]]) {
				continue;
			}
			User *u = [User userWithJsonDictionary:dic]  ;
			[u updateDB] ;
			if ( u != user ) [meetUsers addObject:u];
		}
		[DBConnection commitTransaction];
		// only for the purpose to update users in a meeting
		// skip rest of update
		if ( [chatters isKindOfClass:[NSArray class]] && [chatters count]){
			NSString *messages = @"";
			for( int i = 0 ; i < [chatters count] ; i ++ ) {
				NSDictionary *dic = (NSDictionary*)[chatters objectAtIndex:i] ; 
				NSString *uid = [dic objectForKey:@"user_id"] ;
				if ( uid == (NSString*)[NSNull null] || uid == nil || uid == @"" ) continue ;
				User *u = [User userWithId:[[dic objectForKey:@"user_id"] longValue]];
				NSString *content = [dic objectForKey:@"content"] ;
				messages = [NSString stringWithFormat:@"%@ > %@\n%@",u.name,content,messages] ;
			}
			latestChat = [[NSString stringWithFormat:@"%@", messages] retain];
		} else if (place != nil) {
			latestChat = [[NSString stringWithFormat:@"@%@", place]    retain];
		} else latestChat = [[NSString stringWithFormat:@"@%@", source]    retain];
		return ;
	}
	

	// location display
    NSString *textString = [dic objectForKey:@"city"] ;
	NSString *zipString  = [dic objectForKey:@"zip" ] ;
	NSString *brief		 = [dic objectForKey:@"peers_name_brief"];
	if (description != nil) [description release] ;
	if ( userCount > 1 ) {
        description = [[NSString stringWithFormat:@" met  %@ ", brief]  retain];
    }
	else 
	{
		description = [[NSString stringWithFormat:@" meet with friend"]  retain];
	}
	
	// can add more info by source, html links
    // parse source parameter
    /* NSString *src = [dic objectForKey:@"source"];
    if (src != nil && (id)src != [NSNull null]) {
		if ( source != nil ) [source release];
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
    } */
	if (source != nil ) [source release];
	source = [[NSString stringWithFormat:@" at %@ ( %@ ) ", textString, zipString] retain];
}

- (id)initWithJsonDictionary:(NSDictionary*)dic type:(MeetType)aType user:(User*)aUser
{
	self = [super init];
    [self updateWithJsonDictionary:dic];
    type = aType;
	
	// if we will post Friends' meets in the future
	// there will be user: 
	user = aUser ;
	place = nil  ;
	latestChat = nil;
	meetUsers = nil;
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
	return [self initWithJsonDictionary:dic type:KYMEET_TYPE_UPDATE user:aUser] ;
}

+ (KYMeet*)meetWithJsonDictionary:(NSDictionary*)dic type:(MeetType)type
{
	return [[[KYMeet alloc] initWithJsonDictionary:dic type:type] autorelease];
}

+ (KYMeet*)meetWithId:(sqlite_uint64)aMeetId
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
	s.updateAt              = [stmt getInt32:5];
    s.longitude             = [[stmt getString:6] floatValue];
    s.latitude              = [[stmt getString:7] floatValue];
    s.description           = [stmt getString:8] ;
    s.source                = [stmt getString:9] ;
	s.userCount				= [stmt getInt32:10] ;
			  
	if (s.user == nil) {
		NSLog(@"KYMeet initial with stm error");
        return nil;
    }
    return s;
}

+ (BOOL)isExists:(sqlite_uint64)aMeetId
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

+ (int)getMeetsFromDB:(NSMutableArray*)meets
{
 //   NSMutableDictionary *hash = [NSMutableDictionary dictionary];
	User *user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
    int count = 0;
 //   [meets   addObject:self];
 //   [hash    setObject:self forKey:[NSString stringWithFormat:@"%lld", self.user.userId]];
    
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM meets WHERE userId IN (%d)", user.userId];
	Statement *stmt = [DBConnection statementWithQuery:[sql UTF8String]];
        
	//NSLog(@"Exec %@", sql);
	while ([stmt step] == SQLITE_ROW) {
		//NSString *idStr = [NSString stringWithFormat:@"%lld", [stmt getInt64:0]];
		//NSLog(@"Found %@", idStr);
		//if (![hash objectForKey:idStr]) {
		KYMeet *s = [KYMeet initWithStatement:stmt];
		//[hash setObject:s forKey:idStr];
		[meets addObject:s];
			// Up to 20 meets
		//if (++count >= 20) break;
		//}
	}
	[stmt reset];
    [meets sortUsingFunction:sortByDateDesc context:nil];    
    return count;
}

- (void)insertDB
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO meets VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
        [stmt retain];
    }
    [stmt bindInt64:meetId			forIndex:1];
	[stmt bindInt64:postId		forIndex:2];
	[stmt bindInt32:user.userId forIndex:3];
	[stmt bindInt32:type        forIndex:4];
	[stmt bindInt32:timeAt        forIndex:5];
	[stmt bindInt32:updateAt       forIndex:6];
	[stmt bindString:[NSString stringWithFormat:@"%lf", longitude] forIndex:7];
	[stmt bindString:[NSString stringWithFormat:@"%lf", latitude]  forIndex:8];
    [stmt bindString:description forIndex:9];
    [stmt bindString:source     forIndex:10];
	[stmt bindInt32:userCount   forIndex:11];

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
