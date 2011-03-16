//
//  MeetDetailView.h
//  kaya_meet
//
//  Created by Jun Li on 12/25/10.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "KYMeetClient.h"
#import "KYMeet.h"
#import "LoadCell.h"
#import "BlueTooth.h"
#import "MBProgressHUD.h"
#import "HJManagedImageV.h"
#import "Timeline.h"

@interface MeetDetailView : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate> {
	KYMeet*				  currentMeet ;
	KYMeetClient*         meetDetailClient;
	LoadCell*             loadCell ;
	IBOutlet UITableView *friendsView;
	BluetoothConnect	 *bt ;
	MBProgressHUD		 *HUD;
	IBOutlet UITextView  *messageView;
	IBOutlet UIButton	 *addButton, *sendButton, *hostButton;
	
	NSMutableArray		 *Timelines;
	CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject;
}
@property (readwrite) CFURLRef		  soundFileURLRef;
@property (readonly)  SystemSoundID   soundFileObject;

@property (nonatomic, assign) KYMeet	  *currentMeet;
@property (nonatomic, assign) UITableView *friendsView;
@property (nonatomic, assign) UITableViewCell *TimelineEncounterCell;
@property (nonatomic, assign) UITextView  *messageView;

- (id) initWithMeet:(KYMeet *)meet ;
- (void) getMeetDetails ;
- (void) updateFriendList ;
- (void) addMeet ;
- (void) hostDialog;
- (void) dialog:(NSString *)title message:(NSString *)message ;


- (IBAction) postMessage : (id) sender;
- (IBAction) inviteFriend: (id) sender;
- (IBAction) hostMeet: (id) sender;

@end
