//
//  kaya_meetAppDelegate.h
//  kaya-meet
//
//  Created by Jun Li on 10/25/10.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LoginViewController.h"
//#import "TwitterViewController.h"
#import "FBConnect.h"
#import "RegisterViewController.h"
#import "MeetViewController.h"
#import "MessageViewController.h"
#import "LocationManager.h"
#import "HJObjManager.h"

typedef enum {
    TAB_CIRCLES,
    TAB_ENCOUNTER,
    TAB_SETUP,
    TAB_MEETS,
    TAB_PLACES,
    TAB_MAX,
} TAB_ITEM;


@interface kaya_meetAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIAccelerometerDelegate, FBSessionDelegate, FBRequestDelegate /*, MKReverseGeocoderDelegate*/ > {
    IBOutlet	UIWindow			*window;
    IBOutlet	UITabBarController  *tabBarController;
	
	LoginViewController   *loginView;
//    TwitterViewController *twitterView;
    Facebook                *facebook;
    FBRequest               *fbUser;
    FBRequest               *fbFriends;
    RegisterViewController *registerView;
	MessageViewController *messageView;
	NSString			*screeName;
	int					 selectedTab;
	BOOL				 initialized;
	LocationManager*		location  ;
	HJObjManager*		 objMan;
    NSMutableArray*      cachedImages;
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
//@property (nonatomic, assign) TwitterViewController  *twitterView;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) FBRequest *fbUser;
@property (nonatomic, retain) FBRequest *fbFriends;
@property (nonatomic, assign) MessageViewController  *messageView;
@property (nonatomic, retain) NSString* screenName;
@property (nonatomic, assign) int selectedTab;
@property (nonatomic, assign) HJObjManager *objMan;
@property (nonatomic, retain) NSMutableArray *cachedImages;
@property (nonatomic, readonly) float longitude, latitude, lerror;
@property (readwrite) CFURLRef		  soundFileURLRef;
@property (readonly)  SystemSoundID   soundFileObject;

- (void)alert :(NSString*)title message:(NSString*)detail;
- (void)openLoginView;
- (void)postInit;
- (void)closeLoginView:(NSInteger)selectTab;
- (void)openRegisterView;
- (void)closeRegisterView;
- (void) getLocation;
- (UINavigationController*)getAppTabController:(int)selectTab;
- (void)messageViewAnimationDidFinish ;
+ (BOOL)isMyScreenName:(NSString*)screen_name;
+ (kaya_meetAppDelegate*)getAppDelegate;
- (MeetViewController*)getAppMeetViewController;
- (void)selectSetupView;
- (void)reset;
 - (void)clear;

@end
