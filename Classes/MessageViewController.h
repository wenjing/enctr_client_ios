//
//  MessageViewController.h
//

#import <UIKit/UIKit.h>
#import "KYMeetClient.h"
#import "ProgressWindow.h"
#import "KYMeet.h"
#import "MessageView.h"

@interface MessageViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    IBOutlet UITextView*                text;
    IBOutlet UIToolbar*                 toolbar;
    IBOutlet MessageView*               messageView;
    IBOutlet UITextField*               recipient;
    
   	IBOutlet ProgressWindow*            progressWindow;

    IBOutlet UIBarButtonItem*           sendButton;
    IBOutlet UIBarButtonItem*           photoButton;
    IBOutlet UIActivityIndicatorView*   indicator;

    UIImage*                    selectedPhoto;
    
    KYMeetClient*               connection;
    BOOL                        didPost;
	BOOL						isReplyMessage ;
	BOOL                        recipientIsFirstResponder;
    NSRange                     textRange;

    UINavigationController*     navigation;
}

@property(nonatomic, assign) UINavigationController* navigation;
@property(nonatomic, retain) UIImage*  selectedPhoto;

- (void)postTo:(KYMeet*)mt;
- (void)replyTo:(KYMeet*)mt ofChatId:(uint32_t)cid;
- (void)saveMessage;
- (void)checkProgressWindowState;
- (void)imagePickerControllerDidDisappear;


- (IBAction) close:   (id) sender;
- (IBAction) send:    (id) sender;
- (IBAction) cancel:  (id) sender;
- (IBAction) photos:  (id) sender;
@end
