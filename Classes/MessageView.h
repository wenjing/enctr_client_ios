//
//  MessageView.h


#import <UIKit/UIKit.h>
#import "KYMeet.h"
#import "sqlite3.h"

@interface MessageView : UIView {
    IBOutlet UITextView*        text;
    IBOutlet UILabel*           to;
    IBOutlet UITextField*       recipient;
    IBOutlet UIToolbar*         toolbar;
    IBOutlet UIBarButtonItem*   sendButton;
    IBOutlet UILabel*           charCount;
    
    NSString*                   inReplyToChat;
	uint32_t					InReplyToChatId;
    sqlite_int64				InReplyToMeetId, savedId;  
    NSString*                   undoBuffer;    
	
	BOOL	isReplyFlag ;
}
@property (nonatomic, assign) sqlite_int64 InReplyToMeetId ;
@property (nonatomic, assign) uint32_t     InReplyToChatId ;
@property (nonatomic, assign) BOOL     isReplyFlag ;

- (IBAction) clear:(id)sender;
- (void)editReply:(KYMeet*)mt ofChatId:(uint32_t)cid;
- (void)editMessage:(KYMeet*)mt ;
- (void)setCharCount;
- (void)saveMessage ;
@end
