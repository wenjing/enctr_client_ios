//
//  UserStore.m
//  kaya meet user profile storeage
//  

#import "UserStore.h"

static NSMutableDictionary* users = nil;
static NSMutableDictionary* usersById = nil;

@implementation UserStore

+ (void)initDictionary
{
    if (users == nil) {
        users = [[NSMutableDictionary dictionary] retain];
        usersById = [[NSMutableDictionary dictionary] retain];
    }
}

+ (void)setUser:(User*)user
{
    [UserStore initDictionary];

    [users setObject:user forKey:user.name];
    NSString *key = [NSString stringWithFormat:@"%d", user.userId];
    [usersById setObject:user forKey:key];
}

+ (User*)getUser:(NSString*)name
{
    [UserStore initDictionary];
    
    if ([name isKindOfClass:[NSString class]]) {
        return [users objectForKey:name];
    }
    else {
        return nil;
    }
}

+ (User*)getUserWithId:(uint32_t)aId
{
    [UserStore initDictionary];
    
    NSString *key = [NSString stringWithFormat:@"%d", aId];
    return [usersById objectForKey:key];
}

@end
