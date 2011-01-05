//
//  MeetDetailView.h
//  kaya_meet
//
//  Created by Jun Li on 12/25/10.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "KYMeetClient.h"
#import "KYMeet.h"
#import "LoadCell.h"


@interface MeetDetailView : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate, MKMapViewDelegate> {
	KYMeet*				  currentMeet ;
	KYMeetClient*         meetDetailClient;
	LoadCell*             loadCell ;
	IBOutlet UITableView *friendsView;
	IBOutlet MKMapView	 *mapView ;
	IBOutlet UITextView  *messageView;
	IBOutlet UIButton	 *addButton, *sendButton;
}
@property (nonatomic, assign)  KYMeet *currentMeet ;
@property (nonatomic, assign) UITableView *friendsView;
@property (nonatomic, assign) MKMapView *mapView;
@property (nonatomic, assign) UITextView *messageView;

- (id) initWithMeet:(KYMeet *)meet ;
- (void) getMeetDetails ;
- (void) updateFriendList ;
@end
