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
    sqlite_uint64		InReplyToChatId;
    sqlite_uint64		InReplyToUserId;
    sqlite_uint64		InReplyToMeetId, savedId;  
    NSString*                   undoBuffer;    
	
    BOOL	isReplyFlag, isInviteFlag ;
}
@property (nonatomic, assign) sqlite_uint64 InReplyToChatId ;
@property (nonatomic, assign) sqlite_uint64 InReplyToUserId ;
@property (nonatomic, assign) sqlite_uint64 InReplyToMeetId ;
@property (nonatomic, assign) BOOL     isReplyFlag, isInviteFlag ;

- (IBAction) clear:(id)sender;
- (void)editReply:(sqlite_uint64)cid;
- (void)editMessageUser:(User*)mt ;
- (void)editMessage:(KYMeet*)mt ;
- (void)editInvite:(KYMeet *)mt ;
- (void)setCharCount;
- (void)saveMessage ;
@end
