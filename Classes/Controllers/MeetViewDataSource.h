//
//  MeetVeiwDataSource.h
//
#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "MeetViewCell.h"
#import "MeetDataSource.h"
#import "LocationManager.h"
#import "KYMeetClient.h"
#import "BlueTooth.h"


@interface MeetViewDataSource : MeetDataSource <EGORefreshTableHeaderDelegate, UITableViewDataSource, UITableViewDelegate>
{
	UITableViewController  *controller;
	KYMeetClient*           meetClient;
    int                     insertPosition, from_index ;
    BOOL                    isRestored, reloading ;
	int64_t					latestUserCount, latestPostId;
	NSString*				userConfirmString;
	EGORefreshTableHeaderView *refreshHeaderView;
}

- (id)initWithController:(UITableViewController*)controller;
- (MeetViewCell *)getMeetCell:(UITableView*)tableView atIndex:(int)index ;

- (void)getUserMeets;
- (void)addMeet:(NSMutableDictionary*)param ;
- (void)cancelConnect;

@end
