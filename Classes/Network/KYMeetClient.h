
// Kaya Meet Client.h
//
// By Jun 11/04-2010
// Kaya Labs, Inc.


#import <UIKit/UIKit.h>
#import "KYConnection.h"

typedef enum {
    KAYAMEET_REQUEST_LOGIN,
	KAYAMEET_REQUEST_SIGNIN,
    KAYAMEET_REQUEST_POST_MEET,
	KAYAMEET_REQUEST_POST_MESSAGE,
	KAYAMEET_REQUEST_POST_PHOTO,
	KAYAMEET_REQUEST_GET_MEET,
	KAYAMEET_REQUEST_GET_USERMEETS
} RequestType;

@interface KYMeetClient : KYConnection
{
    RequestType request;
    id          context;
    SEL         action;
    BOOL        hasError;
    NSString*   errorMessage;
    NSString*   errorDetail;
}

@property(nonatomic, readonly) RequestType request;
@property(nonatomic, assign) id context;
@property(nonatomic, assign) BOOL hasError;
@property(nonatomic, copy) NSString* errorMessage;
@property(nonatomic, copy) NSString* errorDetail;

- (id)initWithTarget:(id)delegate action:(SEL)action;
- (void)postMeet:(NSDictionary*)params ;
- (void)getMeet :(NSDictionary*)params withMeetId:(uint32_t)meetId ;
- (void)getMeet :(NSDictionary*)params withPostId:(uint32_t)postId ;
- (void)getUserMeets :(NSDictionary*)params withUserId:(uint32_t)userId;

- (void)postMessage:(NSString*)message toMeetId:(uint64_t)meetId toChatId:(int)chatId photoData:(UIImage*)photo;
- (void)verify;
- (void)alert;

- (NSString *)writeImageToTempFile:(UIImage *)image ;

@end
