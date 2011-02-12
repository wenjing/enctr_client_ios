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


@interface MeetDetailView : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate, MKMapViewDelegate> {
	KYMeet*				  currentMeet ;
	KYMeetClient*         meetDetailClient;
	LoadCell*             loadCell ;
	IBOutlet UITableView *friendsView;
	UIImageView			 *mapView ;
	BluetoothConnect	 *bt ;
	MBProgressHUD		 *HUD;
	IBOutlet UITextView  *messageView;
	IBOutlet UIButton	 *addButton, *sendButton, *hostButton;
	
	CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject;
}
@property (readwrite) CFURLRef		  soundFileURLRef;
@property (readonly)  SystemSoundID   soundFileObject;

@property (nonatomic, assign)  KYMeet *currentMeet ;
@property (nonatomic, assign) UITableView *friendsView;
@property (nonatomic, assign) UIImageView *mapView;
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
