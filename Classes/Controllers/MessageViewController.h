//
//  MessageViewController.h
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "KYMeetClient.h"
#import "ProgressWindow.h"
#import "KYMeet.h"
#import "MessageView.h"

@interface MessageViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,ABPeoplePickerNavigationControllerDelegate>
{
    IBOutlet UITextView*                text;
    IBOutlet UIToolbar*                 toolbar;
    IBOutlet MessageView*               messageView;
    IBOutlet UITextField*               recipient;
    IBOutlet UIButton*					address;
   	IBOutlet ProgressWindow*            progressWindow;
    IBOutlet UINavigationItem*  navigationItem;
	
    IBOutlet UIBarButtonItem*           sendButton;
    IBOutlet UIBarButtonItem*           photoButton;
	IBOutlet UIImageView*				picture;
    IBOutlet UIActivityIndicatorView*   indicator;

    UIImage*                    selectedPhoto;
    
    KYMeetClient*               connection;
    BOOL                        didPost;
	BOOL						isReplyMessage, isInviteMessage ;
	BOOL                        recipientIsFirstResponder;
    NSRange                     textRange;

    UINavigationController*     navigation;
    //delegate to callback when sent
    id                          delegate;
}

@property(nonatomic, assign) UINavigationController* navigation;
@property(nonatomic, retain) UIImage*  selectedPhoto;
@property(nonatomic, assign) UIImageView* picture;
@property(nonatomic, retain) id delegate;

- (void)replyTo:(sqlite3_uint64)cid;
- (void)postToUser:(User*)user;
- (void)postToUserWithId:(sqlite_uint64)userid;
- (void)postTo:(KYMeet*)mt;
- (void)postToWithId:(sqlite_uint64)cid;
- (void)inviteTo:(KYMeet*)mt;
- (void)saveMessage;
- (void)checkProgressWindowState;
- (void)imagePickerControllerDidDisappear;

- (IBAction)showPeoplePickerController;
- (IBAction) close:   (id) sender;
- (IBAction) send:    (id) sender;
- (IBAction) cancel:  (id) sender;
- (IBAction) photos:  (id) sender;
@end
