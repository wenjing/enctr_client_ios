//
//  kaya_meetAppDelegate.m
//  kaya-meet
//
//  Created by Jun Li on 10/25/10.
//  Copyright 2010 Anova Solutions Inc. All rights reserved.
//

#import "kaya_meetAppDelegate.h"
#import "DBConnection.h"

@interface NSObject (kaya_meetAppDelegate)
- (void)didLeaveTab :(UINavigationController*)navigationController;
- (void)didSelectTab:(UINavigationController*)navigationController;
@end

@interface kaya_meetAppDelegate(Private)
- (void)initializeUserDefaults;
- (void)setNextTimer:(NSTimeInterval)interval;
@end

@implementation kaya_meetAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize screenName;
@synthesize loginView;
@synthesize selectedTab;

#pragma mark -
#pragma mark Application lifecycle


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

	[self initializeUserDefaults];
	BOOL forceCreate = [[NSUserDefaults standardUserDefaults] boolForKey:@"clearLocalCache"];
    [DBConnection createEditableCopyOfDatabaseIfNeeded:forceCreate];
    [DBConnection getSharedDatabase];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"clearLocalCache"];
    
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *prevusername = [[NSUserDefaults standardUserDefaults] stringForKey:@"prevusername"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	NSString *sessionToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"KYsessionToken"];	
	int  user_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId"];	
    if (prevusername != nil && [username caseInsensitiveCompare:prevusername] != NSOrderedSame) {
		// delete other user's DB data
        [DBConnection deleteDBCache];
    }
	
	selectedTab = TAB_MEETS;
    tabBarController.selectedIndex = selectedTab;
	[window addSubview:tabBarController.view];
	
    // login if needed.
	
	if ([username length] == 0 || [password length] == 0 || [sessionToken length] == 0 || user_id == 0 ) {
		[self openLoginView];
	}
	else if ( [User userWithId:user_id] == nil ) {
		[self openLoginView];
	}
	else {
		[self postInit];
	}
	[window makeKeyAndVisible];
    return YES;
}

- (void)initializeUserDefaults
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"",                             @"username",
                         @"",                             @"password",
                         @"",                             @"name",
						 @"",							  @"KYsessionToken",
						 [NSNumber numberWithInt:0],      @"KYUserId",
                         [NSNumber numberWithBool:false], @"clearLocalCache",
                         [NSNumber numberWithBool:true],  @"loadAllTabOnLaunch",
                         [NSNumber numberWithInt:5],      @"autoRefresh",
                         [NSNumber numberWithInt:50],     @"launchCount",
                         [NSNumber numberWithInt:13],     @"fontSize",
                         nil];
	
    for (id key in dic) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:key] forKey:key];
        }
    }
}

- (void)openLoginView 
{
	if( loginView ) return ;
	initialized = false;
	loginView = [[[LoginViewController alloc] initWithNibName:@"LoginView" bundle:[NSBundle mainBundle]] autorelease];	
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:0];
    [nav presentModalViewController:loginView animated:YES];
}

- (void)closeLoginView
{
    loginView = nil;
	if ( !initialized )
	{
		[self postInit];
	}

}

- (void) postInit
{
	screeName = [[[NSUserDefaults standardUserDefaults] stringForKey:@"screenName"] retain];
	
	// load views
    NSArray *views = tabBarController.viewControllers;
	UINavigationController* nav = (UINavigationController*)[views objectAtIndex:TAB_MEETS];
	[(MeetViewController*)[nav topViewController] restoreAndLoadMeets:true] ;

	// set auto refresh
	//
    int interval = [[NSUserDefaults standardUserDefaults] integerForKey:@"autoRefresh"];
    autoRefreshInterval = 0;
    if (interval > 0) {
        autoRefreshInterval = interval * 60;
        if (autoRefreshInterval < 180) autoRefreshInterval = 180;
        [self setNextTimer:autoRefreshInterval];
    }
    initialized = true;
}

- (void)setNextTimer:(NSTimeInterval)interval
{
    autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:interval 
												        target:self
													  selector:@selector(autoRefresh:)
													  userInfo:nil
													   repeats:false];    
}

- (void)autoRefresh:(NSTimer*)timer
{
    [lastRefreshDate release];
    lastRefreshDate = [[NSDate date] retain];
    NSArray *views = tabBarController.viewControllers;
    for (int i = 0; i < [views count]; ++i) {
        UINavigationController* nav = (UINavigationController*)[views objectAtIndex:i];
        UIViewController *c = [nav.viewControllers objectAtIndex:0];
        if ([c respondsToSelector:@selector(autoRefresh)]) {
            [c performSelector:@selector(autoRefresh)];
        }
    }
	
    [self setNextTimer:autoRefreshInterval];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [tabBarController release];
	[loginView release];
    [window release];
    [super dealloc];
}

// #pragma mark UITabBarControllerDelegate methods
//
- (void)tabBarController:(UITabBarController *)tabBar didSelectViewController:(UIViewController *)viewController
{
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    UIViewController *c = [nav.viewControllers objectAtIndex:0];
    if ([c respondsToSelector:@selector(didLeaveTab:)]) {
        [c performSelector:@selector(didLeaveTab:nav:)];
    }
    selectedTab = tabBar.selectedIndex;
	
    nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    c = [nav.viewControllers objectAtIndex:0];
    if ([c respondsToSelector:@selector(didSelectTab:)]) {
        [c performSelector:@selector(didSelectTab:nav:)];
    }
}

//
// Common utilities
//

static UIAlertView *sAlert = nil;
static id actionDelegate ;
static SEL clickedAccept ;
- (void)dialog:(NSString*)title message:(NSString*)message action:(SEL)anAction dg:(id)aDelegate
{
	if (sAlert) return;
	sAlert = [[UIAlertView alloc] initWithTitle:title
										message:message
									   delegate:self
							  cancelButtonTitle:@"Accept"
							  otherButtonTitles:@"Cancel", nil];
	clickedAccept  = anAction ;
	actionDelegate = aDelegate;
	[sAlert show];
	[sAlert release];
}

- (void)alert:(NSString*)title message:(NSString*)message
{
    if (sAlert) return;
    
    sAlert = [[UIAlertView alloc] initWithTitle:title
                                        message:message
									   delegate:self
							  cancelButtonTitle:@"Close"
							  otherButtonTitles:nil];
    [sAlert show];
    [sAlert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"click %d",buttonIndex);
	sAlert = nil ;
	if ( buttonIndex == 1 )
	{
		[actionDelegate performSelector:clickedAccept] ;
	}
	sAlert = nil ; 
}

+ (BOOL)isMyScreenName:(NSString*)screen_name
{
    kaya_meetAppDelegate *delegate = [kaya_meetAppDelegate getAppDelegate];
    return ([delegate.screenName caseInsensitiveCompare:screen_name] == NSOrderedSame) ? true : false;
}

+(kaya_meetAppDelegate*)getAppDelegate
{
    return (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
}

-(UINavigationController*)getAppTabController:(int)selectTab
{
	NSArray *views = tabBarController.viewControllers;
	return (UINavigationController*)[views objectAtIndex:selectTab];
}

@end

