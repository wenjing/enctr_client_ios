//
//  MessageView.h


#import <UIKit/UIKit.h>
#import "KYMeet.h"
#import "sqlite3.h"

@interface MessageView : UIView {
    IBOutlet UITextView*        text;
    IBOutlet UILabel*           to;
    IBOutlet UITextField*       recipient;
    IBOutlet UIButton*		address;
    IBOutlet UIToolbar*         toolbar;
    IBOutlet UIBarButtonItem*   sendButton;
    IBOutlet UILabel*           charCount;
    NSString*                   inReplyToChat;
    sqlite_int64		InReplyToChatId;
    sqlite_int64		InReplyToUserId;
    sqlite_int64		InReplyToMeetId, savedId;  
    NSString*                   undoBuffer;    
	
    BOOL	isReplyFlag, isInviteFlag, isUserFlag ;
}
@property (nonatomic, assign) sqlite_int64 InReplyToChatId ;
@property (nonatomic, assign) sqlite_int64 InReplyToUserId ;
@property (nonatomic, assign) sqlite_int64 InReplyToMeetId ;
@property (nonatomic, assign) BOOL     isReplyFlag, isInviteFlag, isUserFlag ;

- (IBAction) clear:(id)sender;
- (void)editReply:(sqlite_int64)cid;
- (void)editMessageUser:(User*)mt ;
- (void)editMessageUserWithId:(sqlite_int64)id;
- (void)editMessage:(KYMeet*)mt ;
- (void)editMessageWithId:(sqlite_int64)id;
- (void)editInvite:(KYMeet *)mt ;
- (void)setCharCount;
- (void)saveMessage ;
@end
