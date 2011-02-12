//
//  kaya_meetAppDelegate.h
//  kaya-meet
//
//  Created by Jun Li on 10/25/10.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LoginViewController.h"
#import "MeetViewController.h"
#import "MessageViewController.h"
#import "LocationManager.h"

typedef enum {
    TAB_MEETS=0,
    TAB_PEOPLE,
    TAB_PLACE,
    TAB_SETUP
} TAB_ITEM;


@interface kaya_meetAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, MKReverseGeocoderDelegate> {
    IBOutlet	UIWindow			*window;
    IBOutlet	UITabBarController  *tabBarController;
	
	LoginViewController   *loginView;
	MessageViewController *messageView;
	NSString			*screeName;
	int					 selectedTab;
	BOOL				 initialized;
	LocationManager*		location  ;
	MKReverseGeocoder*		reverseGeocoder;
	float				 longitude, latitude, lerror  ;
    NSTimeInterval       autoRefreshInterval;
    NSTimer*             autoRefreshTimer;
    NSDate*              lastRefreshDate;
}

@property (nonatomic, readonly) IBOutlet UIWindow *window;
@property (nonatomic, assign) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, assign) LoginViewController    *loginView;
@property (nonatomic, assign) MessageViewController  *messageView;
@property (nonatomic, retain) NSString*	screenName;
@property (nonatomic, assign) int selectedTab;
@property (nonatomic, readonly) float longitude, latitude, lerror;

- (void)alert :(NSString*)title message:(NSString*)detail;
- (void)openLoginView;
- (void)postInit;
- (void)closeLoginView;
- (void) getLocation;
- (UINavigationController*)getAppTabController:(int)selectTab;
- (void)messageViewAnimationDidFinish ;
+ (BOOL)isMyScreenName:(NSString*)screen_name;
+ (kaya_meetAppDelegate*)getAppDelegate;
- (MeetViewController*)getAppMeetViewController;
@end
