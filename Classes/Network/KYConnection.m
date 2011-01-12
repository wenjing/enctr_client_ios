//
//  KYConnection.m
//  Kaya Meet
//
//  Created by Jun on 11/04/2010.
//  Copyright 2010 kaya labs, inc. All rights reserved.
//

#import "KYConnection.h"
#import "StringUtil.h"
#import "DebugUtils.h"

#define NETWORK_TIMEOUT 60.0

@implementation KYConnection

@synthesize buf;
@synthesize statusCode;
@synthesize requestURL;


//NSString *KAYAMEET_FORM_BOUNDARY = @"0xkAyAMeEtB0uNd@rYStRiNg";
NSString *KAYAMEET_FORM_BOUNDARY = @"----------------------------20d19457c122";

- (id)initWithDelegate:(id)aDelegate
{
	self = [super init];
	delegate = aDelegate;
    statusCode = 0;
    needAuth = false;
	return self;
}

- (void)dealloc
{
	[requestURL release];
	[connection release];
	[buf release];
	[super dealloc];
}


// Add basic authentation in the HTTP header
// unsing base64encode
//
- (void)addAuthHeader:(NSMutableURLRequest*)req
{
    if (!needAuth) return;
    
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    
    NSString* auth = [NSString stringWithFormat:@"%@:%@", username, password];
    NSString* basicauth = [NSString stringWithFormat:@"Basic %@", [NSString base64encode:auth]];
	LOG(@"Authentation : %@", basicauth);
    [req setValue:basicauth forHTTPHeaderField:@"Authorization: "];
}

- (void)addAuthTrailer: (NSMutableString *)body
{
	if ( !needAuth ) return ;
	
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];					   
	if ( username != nil && password != nil) {
		[ body appendFormat:@"&email=%@&password=%@",username,password] ;
	}
}

- (void)addSessionToken:(NSMutableURLRequest*)req
{
	if ( !needAuth ) return ;
	// add session cookie
	NSString *sessionToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"KYsessionToken"];
	if ( sessionToken != nil && sessionToken != @"" ) {
		[req setValue:[NSString stringWithFormat:@"remember_token=%@",sessionToken] forHTTPHeaderField:@"Cookie"];
	}
}

- (void)get:(NSString*)aURL body:(NSString *)aBody
{
    [connection release];
	[buf release];
    statusCode = 0;
    self.requestURL = [NSString stringWithFormat:@"%@",aURL] ;
    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [URL autorelease];
	
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:aURL]
						cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                     timeoutInterval:NETWORK_TIMEOUT];
	[req setHTTPMethod:@"GET"];
	[req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
#ifdef _USE_BASIC_AUTHENTICATION
    [self addAuthHeader:req];
#else
	//NSMutableString *body = [NSMutableString stringWithFormat:@"%@", aBody]  ;
	//[self addAuthTrailer:body];
	[self addSessionToken:req];
#endif

	if (aBody) {
		int contentLength = [aBody lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[req setValue:[NSString stringWithFormat:@"%d", contentLength] forHTTPHeaderField:@"Content-Length"];
		[req setHTTPBody:[NSData dataWithBytes:[aBody UTF8String] length:contentLength]];
	}

	buf = [[NSMutableData data] retain];
	connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)post:(NSString*)aURL body:(NSString*)aBody
{
    [connection release];
	[buf release];
    statusCode = 0;
    self.requestURL = aURL;
    
    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [URL autorelease];
	NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]
                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   timeoutInterval:NETWORK_TIMEOUT];
    
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setValue:@"application/json" forHTTPHeaderField:@"Accept"];

#ifdef _USE_BASIC_AUTHENTICATION
    [self addAuthHeader:req];
#else
	NSMutableString *body = [NSMutableString stringWithFormat:@"%@", aBody]  ;
	[self addAuthTrailer:body];
	[self addSessionToken:req];
	
	if (body) {
		int contentLength = [body lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[req setValue:[NSString stringWithFormat:@"%d", contentLength] forHTTPHeaderField:@"Content-Length"];
		[req setHTTPBody:[NSData dataWithBytes:[body UTF8String] length:contentLength]];
    }
#endif
	NSLog(@"post : %@", [req allHTTPHeaderFields]);
	buf = [[NSMutableData data] retain];
	connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)post:(NSString*)aURL data:(NSData*)data
{
    [connection release];
	[buf release];
    statusCode = 0;

    self.requestURL = aURL;

    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [URL autorelease];
	NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]
													cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                    timeoutInterval:NETWORK_TIMEOUT];
    

    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", KAYAMEET_FORM_BOUNDARY];
    [req setHTTPMethod:@"POST"];
	[req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
	[req setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
	[self addAuthHeader:req];
    [req setHTTPBody:data];
	
	NSLog(@"post : %@\n%@", [req allHTTPHeaderFields],[req HTTPBody]);
	buf = [[NSMutableData data] retain];
	connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)cancel
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;    
    if (connection) {
        [connection cancel];
        [connection autorelease];
        connection = nil;
    }
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSHTTPURLResponse *resp = (NSHTTPURLResponse*)aResponse;
    if (resp) {
        statusCode = resp.statusCode;
        NSLog(@"Response: %d", statusCode);
		[self KYConnectionDidReceieveResponse:aResponse];
    }

	[buf setLength:0];
}

- (void)KYConnectionDidReceieveResponse:(NSURLResponse *)aResponse
{
	// leave for subclass implement
}


- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data
{
	[buf appendData:data];
}

- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    

    
    NSString* msg = [NSString stringWithFormat:@"Error: %@ %@",
                     [error localizedDescription],
                     [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]];
    
    NSLog(@"Connection failed: %@", msg);
    
    [self KYConnectionDidFailWithError:error];
	[connection autorelease];
	 connection = nil;
	[buf autorelease];
	 buf = nil;
}


- (void)KYConnectionDidFailWithError:(NSError*)error
{
    // To be implemented in subclass
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString* s = [[[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding] autorelease];
    
    [self KYConnectionDidFinishLoading:s];

    [connection autorelease];
    [buf autorelease];
    buf = nil;
 	connection = nil;
}

- (void)KYConnectionDidFinishLoading:(NSString*)content
{
    // To be implemented in subclass
	// return back to connectionDidFinishLoading
}


// Utilities


+ (NSString*)getStringFromUrl: (NSString*) url needle:(NSString *) needle {
	NSString * str = nil;
	NSRange start = [url rangeOfString:needle];
	if (start.location != NSNotFound) {
		NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
		NSUInteger offset = start.location+start.length;
		str = end.location == NSNotFound
		? [url substringFromIndex:offset]
		: [url substringWithRange:NSMakeRange(offset, end.location)];  
		str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
	}
	return str;
}

+ (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
	if (params) {
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
			NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																						  NULL, /* allocator */
																						  (CFStringRef)value,
																						  NULL, /* charactersToLeaveUnescaped */
																						  (CFStringRef)@"!*'();:&=+$,/?%#[]@",
																						  kCFStringEncodingUTF8);
			
			[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
			[escaped_value release];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
		
		NSLog(@"%@",url);
		return [NSURL URLWithString:url];
	} else {
		return [NSURL URLWithString:baseURL];
	}
}

+ (NSString*)generateBodyString:(NSString*)baseBody params:(NSDictionary*)params {
	if (params) {
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator) {
			 NSString* value = [params objectForKey:key];
			[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		
		NSLog(@"%@",query);
		if ( baseBody == nil || baseBody == @"" ) 
			return query ;
			//return [query encodeAsURIComponent];
		else {
			NSString* body  = [NSString stringWithFormat:@"%@&%@", baseBody, query];
			//return [body encodeAsURIComponent];
			return body ;
		}
	} else if ( baseBody ) {
		// return [baseBody encodeAsURIComponent];
		return baseBody;
	} else return nil ;
}

- (NSString*) nameValString: (NSDictionary*) dict {
	NSArray* keys = [dict allKeys];
	NSString* result = [NSString string];
	int i;
	for (i = 0; i < [keys count]; i++) {
        result = [result stringByAppendingString:
                  [@"--" stringByAppendingString:
                   [KAYAMEET_FORM_BOUNDARY stringByAppendingString:
                    [@"\r\nContent-Disposition: form-data; name=\"" stringByAppendingString:
                     [[keys objectAtIndex: i] stringByAppendingString:
                      [@"\"\r\n" stringByAppendingString:
                       [[dict valueForKey: [keys objectAtIndex: i]] stringByAppendingString: @"\r\n\r\n"]]]]]]];
		/*
		result = [result stringByAppendingString:
                    [@"\r\nContent-Disposition: form-data; name=\"" stringByAppendingString:
                     [[keys objectAtIndex: i] stringByAppendingString:
                      [@"\"\r\n" stringByAppendingString:
                       [[dict valueForKey: [keys objectAtIndex: i]] stringByAppendingString:
						[@"\r\n" stringByAppendingString:
						 [@"--" stringByAppendingString:[KAYAMEET_FORM_BOUNDARY stringByAppendingString:@"\r\n"]]]]]]]];
		 */
	}
	
	return result;
}

@end
