//
//  MeetVeiwDataSource.h
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MeetViewCell.h"
#import "MeetDataSource.h"
#import "LocationManager.h"
#import "KYMeetClient.h"

@interface MeetViewDataSource : MeetDataSource <UITableViewDataSource, UITableViewDelegate, MKReverseGeocoderDelegate>
{
	UITableViewController  *controller;
	KYMeetClient*           meetClient;
    int                     insertPosition ;
    BOOL                    isRestored;
	MKReverseGeocoder*		reverseGeocoder;
	LocationManager*		location  ;
	float		 longitude, latitude  ;
}

- (id)initWithController:(UITableViewController*)controller;
- (MeetViewCell *)getMeetCell:(UITableView*)tableView atIndex:(int)index ;

- (void)getUserMeets;
- (void)addMeet ;
- (void)getLocation;

@end
