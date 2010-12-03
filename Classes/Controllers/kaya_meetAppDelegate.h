//
//  kaya_meetAppDelegate.h
//  kaya-meet
//
//  Created by Jun Li on 10/25/10.
//  Copyright 2010 Anova Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MeetViewController.h"
#import "SetupViewController.h"

typedef enum {
    TAB_MEETS=0,
    TAB_SEARCH,
    TAB_PLACE,
    TAB_SETUP
} TAB_ITEM;


@interface kaya_meetAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    IBOutlet	UIWindow			*window;
    IBOutlet	UITabBarController  *tabBarController;
	
	LoginViewController *loginView;

	NSString			*screeName;
	int					 selectedTab;
	BOOL				 initialized;
    NSTimeInterval       autoRefreshInterval;
    NSTimer*             autoRefreshTimer;
    NSDate*              lastRefreshDate;
	
}

@property (nonatomic, readonly) IBOutlet UIWindow *window;
@property (nonatomic, assign) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, assign) LoginViewController *loginView;
@property (nonatomic, retain) NSString*	screenName;
@property (nonatomic, assign) int selectedTab;

- (void)alert:(NSString*)title message:(NSString*)detail;
- (void)openLoginView;
- (void)postInit;
- (void)closeLoginView;
- (UINavigationController*)getAppTabController:(int)selectTab;

+ (BOOL)isMyScreenName:(NSString*)screen_name;
+ (kaya_meetAppDelegate*)getAppDelegate;

@end
