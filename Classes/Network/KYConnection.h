//
//  KYConnection.h
//  kaya-meet
//
//  Created by Jun on 11/04/10.
//  Copyright 2010 kaya labs, inc. All rights reserved.
//

extern NSString *KAYAMEET_FORM_BOUNDARY;

@interface KYConnection : NSObject
{
  id                  delegate;
  NSString*           requestURL;
  NSURLConnection*    connection;
  NSMutableData*      buf;
  int                 statusCode;
  BOOL                needAuth;
}

@property (nonatomic, readonly) NSMutableData* buf;
@property (nonatomic, assign) int statusCode;
@property (nonatomic, copy) NSString* requestURL;

- (id)initWithDelegate:(id)delegate;
- (void)get :(NSString*)URL  param:(NSDictionary*)params;
- (void)post:(NSString*)aURL body:(NSString*)body;
- (void)post:(NSString*)aURL data:(NSData*)data;
- (void)put:(NSString*)aURL body:(NSString*)body;
- (void)put:(NSString*)aURL data:(NSData*)data;
- (void)delete:(NSString*)aURL;
- (void)cancel;

- (void)postOrPut:(NSString*)aURL body:(NSString*)body cmd:(NSString*)cmd;
- (void)postOrPut:(NSString*)aURL data:(NSData*)data cmd:(NSString*)cmd;

- (void)KYConnectionDidFailWithError:(NSError*)error;
- (void)KYConnectionDidFinishLoading:(NSString*)content;
- (void)KYConnectionDidReceieveResponse:(NSURLResponse *)aResponse;

- (NSString *)nameValString:(NSDictionary *)dict ;

+ (NSString *)getStringFromUrl:(NSString*) url needle:(NSString *) needle;
+ (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params;
+ (NSString*)generateBodyString:(NSString*)baseBody params:(NSDictionary*)params;

@end
