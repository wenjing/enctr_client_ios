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
#import "HJObjManager.h"

typedef enum {
    TAB_CIRCLES,
    TAB_MEETS,
    TAB_ENCOUNTER,
    TAB_PLACES,
    TAB_SETUP
} TAB_ITEM;


@interface kaya_meetAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIAccelerometerDelegate/*, MKReverseGeocoderDelegate*/> {
    IBOutlet	UIWindow			*window;
    IBOutlet	UITabBarController  *tabBarController;
	
	LoginViewController   *loginView;
	MessageViewController *messageView;
	NSString			*screeName;
	int					 selectedTab;
	BOOL				 initialized;
	LocationManager*		location  ;
	HJObjManager*		 objMan;
//	MKReverseGeocoder*		reverseGeocoder;
	float				 longitude, latitude, lerror  ;
    NSTimeInterval       autoRefreshInterval;
    NSTimer*             autoRefreshTimer;
    NSDate*              lastRefreshDate;
    
    //accleerameter
    HighpassFilter          *filter;
    CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject;
}

@property (nonatomic, readonly) IBOutlet UIWindow *window;
@property (nonatomic, assign) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, assign) LoginViewController    *loginView;
@property (nonatomic, assign) MessageViewController  *messageView;
@property (nonatomic, retain) NSString*	screenName;
@property (nonatomic, assign) int selectedTab;
@property (nonatomic, assign) HJObjManager *objMan;
@property (nonatomic, readonly) float longitude, latitude, lerror;
@property (readwrite) CFURLRef		  soundFileURLRef;
@property (readonly)  SystemSoundID   soundFileObject;

- (void)alert :(NSString*)title message:(NSString*)detail;
- (void)openLoginView;
- (void)postInit;
- (void)closeLoginView:(NSInteger)selectTab;
- (void) getLocation;
- (UINavigationController*)getAppTabController:(int)selectTab;
- (void)messageViewAnimationDidFinish ;
+ (BOOL)isMyScreenName:(NSString*)screen_name;
+ (kaya_meetAppDelegate*)getAppDelegate;
- (MeetViewController*)getAppMeetViewController;
- (void)selectSetupView;

@end
