//
//  kaya_meetAppDelegate.m
//  kaya-meet
//
//  Created by Jun Li on 10/25/10.
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
@synthesize messageView;
@synthesize selectedTab;
@synthesize objMan;

@synthesize longitude, latitude, lerror;

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
	int  user_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId"];	
    if (prevusername != nil && [username caseInsensitiveCompare:prevusername] != NSOrderedSame) {
		// delete other user's DB data
        [DBConnection deleteDBCache];
    }
	
	messageView = nil ;
	objMan		= nil ;
	selectedTab = TAB_CIRCLES;
    tabBarController.selectedIndex = selectedTab;
	tabBarController.delegate = self ;
	[window addSubview:tabBarController.view];
	
    // login if needed.
	
	if ([username length] == 0 || [password length] == 0 ||  user_id == 0 ) {
		[self openLoginView];
	}
	else if ( [User userWithId:user_id] == nil ) {
		[self openLoginView];
	}
	else {
		[self postInit];
	}
	
	// turn on this for on phone logging
#if 0	
#if TARGET_IPHONE_SIMULATOR == 0
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
#endif
#endif
	
	[window makeKeyAndVisible];
    return YES;
}

- (void)initializeUserDefaults
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"",                             @"username",
                         @"",                             @"password",
                         @"",                             @"name",
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
    // Bring to default view
    self.selectedTab = TAB_CIRCLES;
    self.tabBarController.selectedIndex = TAB_CIRCLES;
}

- (void) postInit
{
	screeName = [[[NSUserDefaults standardUserDefaults] stringForKey:@"screenName"] retain];
	
	// load views
        //NSArray *views = tabBarController.viewControllers;
	//UINavigationController* nav = (UINavigationController*)[views objectAtIndex:TAB_MEETS];
	//[(MeetViewController*)[nav topViewController] restoreAndLoadMeets:true] ;

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
	[self getLocation] ;
    [self setNextTimer:autoRefreshInterval];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	if (autoRefreshTimer) {
        [autoRefreshTimer invalidate];
        autoRefreshTimer = nil;
    }
	
    if (messageView != nil) {
        [self.messageView saveMessage];
    }
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
	[self getLocation];
	if (lastRefreshDate == nil) {
        lastRefreshDate = [[NSDate date] retain];
    }
    else if (autoRefreshInterval) {
        NSDate *now = [NSDate date];
        NSTimeInterval diff = autoRefreshInterval - [now timeIntervalSinceDate:lastRefreshDate];
        if (diff < 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            diff = 2.0;
        }
        [self setNextTimer:diff];
    }
	
    if (messageView != nil) {
        [self.messageView checkProgressWindowState];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	if (messageView != nil) {
        [self.messageView saveMessage];
        [messageView release];
    }
    [DBConnection closeDatabase];
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
	[location release];
	[objMan release];
    [super dealloc];
}

// #pragma mark UITabBarControllerDelegate methods
//
- (void)tabBarController:(UITabBarController *)tabBar didSelectViewController:(UIViewController *)viewController
{
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    UIViewController *c = [nav.viewControllers objectAtIndex:0];
    if ([c respondsToSelector:@selector(didLeaveTab:)]) {
        [c didLeaveTab:nav];
    }
    selectedTab = tabBar.selectedIndex;
	
    nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    c = [nav.viewControllers objectAtIndex:0];
    if ([c respondsToSelector:@selector(didSelectTab:)]) {
        [c didSelectTab:nav];
    }
}

// message view initialization

- (MessageViewController*)messageView
{
    if (messageView == nil) {
        messageView = [[MessageViewController alloc] initWithNibName:@"MessageView" bundle:nil];
    }
    messageView.navigation = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    return messageView;
}

- (HJObjManager *)objMan 
{
	if (objMan == nil) {
		// Image cache 
		objMan = [[HJObjManager alloc] init] ;
		NSString* cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/imgcache/Cirkle/"] ;
		HJMOFileCache* fileCache = [[[HJMOFileCache alloc] initWithRootPath:cacheDirectory] autorelease];
		objMan.fileCache = fileCache;
		
		fileCache.fileCountLimit = 100;
		fileCache.fileAgeLimit = 60*60*24*7; //1 week
		[fileCache trimCacheUsingBackgroundThread];
	}
	return objMan;
}

// message view return screen
//
- (void)messageViewAnimationDidFinish
{
    UINavigationController *nav = nil;
    if ( selectedTab == TAB_MEETS) {
        nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:TAB_MEETS];
    }
    else if (selectedTab == TAB_PLACES) {
        nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:TAB_PLACES];
    }
    UIViewController *c = nav.topViewController;
    if ([c respondsToSelector:@selector(messageViewAnimationDidFinish)]) {
        [c performSelector:@selector(messageViewAnimationDidFinish)];
    }
}

/* Web View
- (void)openWebView:(NSString*)url on:(UINavigationController*)nav
{
    if (webView == nil) {
        webView = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
    }
    webView.hidesBottomBarWhenPushed = YES;
    [webView setUrl:url];
    [nav pushViewController:webView animated:YES];
}

- (void)openWebView:(NSString*)url
{
    if (webView == nil) {
        webView = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
    }
    webView.hidesBottomBarWhenPushed = YES;
    [webView setUrl:url];
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    [nav pushViewController:webView animated:YES];
}
*/

// location 
//
// LocationManager delegate
//
- (void) getLocation
{
	if ( location == nil ) {
		location = [[LocationManager alloc] initWithDelegate:self];
	}
	[location getCurrentLocation];
}

- (void)locationManagerDidUpdateLocation:(LocationManager*)manager location:(CLLocation*)alocation
{
	if (latitude==0.0 || longitude==0.0) {
		latitude  = alocation.coordinate.latitude;
		longitude = alocation.coordinate.longitude;
		lerror = [alocation horizontalAccuracy] ;
	}
}

- (void)locationManagerDidReceiveLocation:(LocationManager*)manager location:(CLLocation*)alocation
{
    latitude  = alocation.coordinate.latitude;
    longitude = alocation.coordinate.longitude;
	lerror = [alocation horizontalAccuracy] ;
	//	reverseGeocoder =
	//	[[MKReverseGeocoder alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude,longitude)];
	//    reverseGeocoder.delegate = self;
	//    [reverseGeocoder start];
}

- (void)locationManagerDidFail:(LocationManager*)manager
{
    lerror = 10000 ;
	//NSLog(@"Can't get current location.");
}

/* -- don't use Geocoder now

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    //addressString = [NSString stringWithFormat:@"%@ %@ (%@)",placemark.thoroughfare, placemark.locality, placemark.postalCode];
	//NSLog(@"place %@",addressString);
	[reverseGeocoder release];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	// NSLog(@"MKReverseGeocoder has failed. %@",error);
	//addressString = @"At Location" ;
	[reverseGeocoder release];
}				 

 -- */

//
// Common utilities
//

static UIAlertView *sAlert = nil ;

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
    sAlert = nil;
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

-(MeetViewController*)getAppMeetViewController
{
	UINavigationController* nav = (UINavigationController*)[self getAppTabController:TAB_MEETS];
	return (MeetViewController*)[nav.viewControllers objectAtIndex:0]  ;
}

@end

