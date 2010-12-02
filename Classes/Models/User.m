#import "User.h"
#import "DBConnection.h"
#import "StringUtil.h"
#import "UserStore.h"

@implementation User

@synthesize userId;
@synthesize name;
@synthesize screenName;
@synthesize email;
@synthesize location;
@synthesize meetsCount;
@synthesize profileImageUrl;
@synthesize notifications;

- (void)updateWithJSonDictionary:(NSDictionary*)dic
{
    [name release];
    [screenName release];
	[email release];
    [location release];
    [profileImageUrl release];
    
    userId          = [[dic objectForKey:@"id"] longValue];
    
    name            = [dic objectForKey:@"name"];
//	screenName      = [dic objectForKey:@"screen_name"];
	screenName		= [dic objectForKey:@"name"];
	email			= [dic objectForKey:@"email"];
	location        = [dic objectForKey:@"location"];
    profileImageUrl = [dic objectForKey:@"user_avatar"];

    meetsCount		= ([dic objectForKey:@"meets_count"]     == [NSNull null]) ? 0 : [[dic objectForKey:@"meets_count"] longValue];
    notifications   = ([dic objectForKey:@"notifications"]   == [NSNull null]) ? 0 : [[dic objectForKey:@"notifications"] boolValue];
    
    if ((id)name == [NSNull null]) name = @"";
    if ((id)screenName == [NSNull null]) screenName = @"";
    if ((id)location == [NSNull null]) {
			location = @"";
			[location retain];
	} else {
			location = [[location unescapeHTML] retain];
	}

    if ((id)profileImageUrl == [NSNull null]){
			profileImageUrl = @"";
		[profileImageUrl retain];
	} else {
		profileImageUrl = [[profileImageUrl unescapeHTML] retain];
	}
    [name retain];
    [screenName retain];
	[email retain];
}

- (id)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [super init];
    
    [self updateWithJSonDictionary:dic];
	
	return self;
}

+ (User*)userWithId:(uint32_t)aId
{
    User *user = [UserStore getUserWithId:(uint32_t)aId];
    
    if (user) return user;
    
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT * FROM users WHERE user_id = ?"];
        [stmt retain];
    }
    
    [stmt bindInt32:aId forIndex:1];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        return nil;
    }
    
    user = [[[User alloc] init] autorelease];
    user.userId           = [stmt getInt32:0];
    user.name             = [stmt getString:1];
    user.screenName		  = [stmt getString:2];
	user.email			  = [stmt getString:3];
    user.location         = [stmt getString:4];
    user.meetsCount		  = [stmt getInt32:5];
    user.profileImageUrl  = [stmt getString:6];

    [stmt reset];
    [UserStore setUser:user];
    return user;
}

+ (User*)userWithJsonDictionary:(NSDictionary*)dic
{
    User *u = [UserStore getUser:[dic objectForKey:@"name"]];
    if (u) {
        [u updateWithJSonDictionary:dic];
        return u;
    }
    
    u = [[User alloc] initWithJsonDictionary:dic];
    [UserStore setUser:u];
    return u;
}

- (void)updateDB
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO users VALUES(?, ?, ?, ?, ?, ?, ?)"];
        [stmt retain];
    }
    [stmt bindInt32:userId              forIndex:1];
    [stmt bindString:name               forIndex:2];
    [stmt bindString:screenName         forIndex:3];
	[stmt bindString:email				forIndex:4];
    [stmt bindString:location           forIndex:5];
    [stmt bindInt32:meetsCount			forIndex:6];
    [stmt bindString:profileImageUrl    forIndex:7];

    if ([stmt step] != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

- (void)dealloc
{
    [location release];
    [email release];
    [name release];
    [screenName release];
    [profileImageUrl release];
   	[super dealloc];
}

@end
