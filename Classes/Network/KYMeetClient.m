//
//  KYMeetClient.m
//  Kaya Meet
//
//  Copyright Kaya Labs, Inc. All rights reserved.
//

#import "kaya_meetAppDelegate.h"
#import "KYMeetClient.h"
#import "StringUtil.h"
#import "JSON.h"


@implementation KYMeetClient

@synthesize request;
@synthesize context;
@synthesize hasError;
@synthesize errorMessage;
@synthesize errorDetail;

- (id)initWithTarget:(id)aDelegate action:(SEL)anAction
{
    [super initWithDelegate:aDelegate];
    action = anAction;
    hasError = false;
    return self;
}

- (void)dealloc
{
    [errorMessage release];
    [errorDetail release];
    [super dealloc];
}

- (void)getUserMeets:(NSDictionary*)params withUserId:(uint32_t)userId
{
	needAuth      = true;
//	uint32_t user_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId"] ;
    NSString *url = [NSString stringWithFormat:@"http://www.kayameet.com/users/%ld", userId];
//	NSString *body = [KYConnection generateBodyString:nil params:params ] ;
	request = KAYAMEET_REQUEST_GET_USERMEETS;
	// can pass parameters through body if needed
    [super get:url body:nil]; 
}


// get meet details by the meetId
- (void)getMeet:(NSDictionary*)params withMeetId:(uint32_t)meetId
{
	needAuth      = true;
    NSString *url = [NSString stringWithFormat:@"http://www.kayameet.com/meets/%ld", meetId];
	NSString *body = [KYConnection generateBodyString:nil params:params ] ;
	request = KAYAMEET_REQUEST_GET_MEET;
	// can pass parameters through body if needed
    [super get:url body:body];
}

// get posted meet update until the meetId show
- (void)getMeet:(NSDictionary*)params withPostId:(uint32_t)postId
{
	needAuth      = true;
    NSString *url = [NSString stringWithFormat:@"http://www.kayameet.com/mposts/%ld", postId];
	NSString *body = [KYConnection generateBodyString:nil params:params ] ;
	request = KAYAMEET_REQUEST_GET_MEET;
	// can pass parameters through body if needed
    [super get:url body:body];
}

// post meet 

- (void)postMeet:(NSDictionary*)params
{
    needAuth = true;
	request = KAYAMEET_REQUEST_POST_MEET;
    NSString* url = @"http://www.kayameet.com/mposts";
    NSString *postString = [KYConnection generateBodyString:nil params:params];
    [self post:url body:postString];
}

// login
- (void)verify
{
    needAuth = true;
	NSString* url = @"http://www.kayameet.com/sessions";
	request = KAYAMEET_REQUEST_LOGIN;
    [super post:url body:nil];
}

- (void)authError
{
    self.errorMessage = @"Authentication Failed";
    self.errorDetail  = @"Wrong username/Email and password combination.";    
    [delegate performSelector:action withObject:self withObject:nil];    
}

- (void)KYConnectionDidFailWithError:(NSError*)error
{
    hasError = true;
    if (error.code ==  NSURLErrorUserCancelledAuthentication) {
        statusCode = 401;
        [self authError];
    }
    else {
        self.errorMessage = @"Connection Failed";
        self.errorDetail  = [error localizedDescription];
        [delegate performSelector:action withObject:self withObject:nil];
    }
	[self autorelease];
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        NSLog(@"Authentication Challenge");
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
        NSURLCredential* cred = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
    } else {
        NSLog(@"Failed auth (%d times)", [challenge previousFailureCount]);
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    hasError = true;
    [self authError];
    [self autorelease];
}

- (void)KYConnectionDidFinishLoading:(NSString*)content
{
    switch (statusCode) {
        case 401: // Not Authorized: either you need to provide authentication credentials, or the credentials provided aren't valid.
            hasError = true;
            [self authError];
            goto out;
            
        case 304: // Not Modified: there was no new data to return.
            [delegate performSelector:action withObject:self withObject:nil];
            goto out;
			
		case 200: // OK: everything went awesome.
        case 400: // Bad Request: your request is invalid, and we'll return an error message that tells you why. 
        case 403: // Forbidden: we understand your request, but are refusing to fulfill it.  An accompanying error message should explain why.
            break;
                
        case 404: // Not Found: either you're requesting an invalid URI or the resource in question doesn't exist (ex: no such user). 
        case 500: // Internal Server Error: we did something wrong.  Please post to the group about it and the Twitter team will investigate.
        case 502: // Bad Gateway: returned if  is down or being upgraded.
        case 503: // Service Unavailable: the  servers are up, but are overloaded with requests.  Try again later.
        default:
        {
            hasError = true;
            self.errorMessage = @"Server responded with an error";
            self.errorDetail  = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
            [delegate performSelector:action withObject:self withObject:nil];
            goto out;
        }
    }

    NSObject *obj = [content JSONValue];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)obj;
        NSString *msg = [dic objectForKey:@"error"];
        if (msg) {
            NSLog(@"Server responded with an error: %@", msg);
            hasError = true;
            self.errorMessage = @" Server Error";
            self.errorDetail  = msg;
        }

    }
    
    [delegate performSelector:action withObject:self withObject:obj];
    
  out:
    [self autorelease];
}

- (void)KYConnectionDidReceieveResponse:(NSURLResponse *)aResponse
{
	NSHTTPURLResponse *resp = (NSHTTPURLResponse*)aResponse;
	if (request == KAYAMEET_REQUEST_LOGIN && resp.statusCode / 100 == 2 ) 
	{
		// store session token
		// NSLog(@"%@", resp.allHeaderFields);
		NSString *cookieString = [resp.allHeaderFields objectForKey:@"Set-Cookie"];
		if( cookieString != nil ) {
			NSString *sessionToken = [KYConnection getStringFromUrl:cookieString needle:@"remember_token="];
			if ( sessionToken == nil || sessionToken == @"" )
			{
				hasError = true ;
				self.errorMessage = @" Server Error" ;
				self.errorDetail  = @" Authentication error, missing session token" ;
				return;
			}
			[[NSUserDefaults standardUserDefaults] setObject:sessionToken forKey:@"KYsessionToken"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		else {
			hasError = true ;
			self.errorMessage = @" Server Error" ;
            self.errorDetail  = @" Authentication error, missing session token" ;
		}
	}
}

- (void)alert
{
    [[kaya_meetAppDelegate getAppDelegate] alert:errorMessage message:errorDetail];
}

// 

@end
