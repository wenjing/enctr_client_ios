//
//  kaya_meetAppDelegate.h
//  kaya-meet
//
//  Created by Jun Li on 10/25/10.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MeetViewController.h"
#import "MessageViewController.h"

typedef enum {
    TAB_MEETS=0,
    TAB_PEOPLE,
    TAB_PLACE,
    TAB_SETUP
} TAB_ITEM;


@interface kaya_meetAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    IBOutlet	UIWindow			*window;
    IBOutlet	UITabBarController  *tabBarController;
	
	LoginViewController   *loginView;
	MessageViewController *messageView;
	NSString			*screeName;
	int					 selectedTab;
	BOOL				 initialized;
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

- (void)alert:(NSString*)title message:(NSString*)detail;
- (void)dialog:(NSString*)title message:(NSString*)detail action:(SEL)anAction dg:(id)aDelegate;
- (void)openLoginView;
- (void)postInit;
- (void)closeLoginView;
- (UINavigationController*)getAppTabController:(int)selectTab;
- (void)messageViewAnimationDidFinish ;
+ (BOOL)isMyScreenName:(NSString*)screen_name;
+ (kaya_meetAppDelegate*)getAppDelegate;

@end
