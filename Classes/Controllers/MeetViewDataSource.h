//
//  MeetVeiwDataSource.h
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MeetViewCell.h"
#import "MeetDataSource.h"
#import "LocationManager.h"
#import "KYMeetClient.h"
#import "BlueTooth.h"


@interface MeetViewDataSource : MeetDataSource <UITableViewDataSource, UITableViewDelegate, MKReverseGeocoderDelegate>
{
	UITableViewController  *controller;
	KYMeetClient*           meetClient;
    int                     insertPosition, from_index ;
    BOOL                    isRestored;
	MKReverseGeocoder*		reverseGeocoder;
	LocationManager*		location  ;
	float					longitude, latitude, lerror  ;
	int64_t					latestUserCount, latestPostId;
	NSString*				userConfirmString;
}

- (id)initWithController:(UITableViewController*)controller;
- (MeetViewCell *)getMeetCell:(UITableView*)tableView atIndex:(int)index ;

- (void)getUserMeets;
- (void)addMeet:(BluetoothConnect*)bt ;
- (void)getLocation;

- (NSString *)getUserNameList:(NSMutableArray *)ar;
- (NSString *)dateString:(time_t)at;
@end
