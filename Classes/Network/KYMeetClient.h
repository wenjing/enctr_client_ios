
// Kaya Meet Client.h
//
// By Jun 11/04-2010
// Kaya Labs, Inc.


#import <UIKit/UIKit.h>
#import "KYConnection.h"
#import "User.h"

typedef enum {
  KAYAMEET_REQUEST_LOGIN,
  KAYAMEET_REQUEST_SIGNIN,
  KAYAMEET_REQUEST_POST_INVITE,
  KAYAMEET_REQUEST_POST_USER,
  KAYAMEET_REQUEST_PUT_USER,
  KAYAMEET_REQUEST_POST_MEET,
  KAYAMEET_REQUEST_POST_MESSAGE,
  KAYAMEET_REQUEST_POST_USERMESSAGE,
  KAYAMEET_REQUEST_POST_PHOTO,
  KAYAMEET_REQUEST_GET_USER,
  KAYAMEET_REQUEST_GET_MEET,
  KAYAMEET_REQUEST_GET_USERMEETS,
  KAYAMEET_REQUEST_GET_TIMELINES,
  KAYAMEET_REQUEST_GET_CIRKLES
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

- (void)postUser:(NSDictionary*)params withUser:(User*)user;
- (void)getUser :(NSDictionary*)params withUserId:(uint32_t)userId;

- (void)postMeet:(NSDictionary*)params ;
- (void)getMeet :(NSDictionary*)params withMeetId:(uint32_t)meetId ;
- (void)getMeet :(NSDictionary*)params withPostId:(uint32_t)postId ;
- (void)getUserMeets :(NSDictionary*)params withUserId:(uint32_t)userId;

- (void)getNews     :(NSDictionary*)params withUserId:(uint32_t)userId;
- (void)getNews     :(NSDictionary*)params withUserId:(uint32_t)userId withFriendId:(uint32_t)friendId;
- (void)getNews     :(NSDictionary*)params withUserId:(uint32_t)userId withCirkleId:(uint32_t)cirkleId;
- (void)getCirkles  :(NSDictionary*)params withUserId:(uint32_t)userId;

- (void)postMessage:(NSString*)message toMeetId:(uint64_t)meetId photoData:(UIImage*)photo;
- (void)postMessage:(NSString*)message toUserId:(uint64_t)meetId photoData:(UIImage*)photo;
- (void)postMessage:(NSString*)message toChatId:(uint64_t)meetId photoData:(UIImage*)photo;
- (void)postMessage:(NSString*)message toUrl:(NSString*)url photoData:(UIImage*)photo;
- (void)postInvite:(NSString*)emails byUserId:(uint32_t)userId byMeetId:(uint64_t)meetId custMessage:(NSString*)message;
- (void)verify;
- (void)alert;

- (void)writeImageToTempFile:(UIImage *)image ;

@end
