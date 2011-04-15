//
//  LoginViewController.m
//
//  Created by Jun Li on 10/27/10.
//

#import "LoginViewController.h"
#import "kaya_meetAppDelegate.h"
#import "REstring.h"
#import "KYMeetClient.h"
#import "User.h"
#import "CirkleViewController.h"
#import "SetupViewController.h"

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		self.wantsFullScreenLayout = YES; // we want to overlap the status bar.
		
		// when presented, we want to display using a cross dissolve
		self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	}
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
    // If the settings are empty, focus to username text area.
	NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	username_field.text = user;
	password_field.text = pass;
    
    // Create signup button
    UIButton *signupButton = [[UIButton alloc] initWithFrame:CGRectMake(107.0f, 331.0f, 106.0f, 37.0f)];
    
    [signupButton setBackgroundImage:[[UIImage imageNamed:@"green-button-sm.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
    
    signupButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    signupButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [signupButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    signupButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [self.view addSubview:signupButton];
    
    [signupButton addTarget:self action:@selector(signup:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)done: (id)sender
{
//	if (![username_field.text matches:@"^[0-9A-Za-z_@.]+$" withSubstring:nil]) {
//        [[kaya_meetAppDelegate getAppDelegate] alert:@"Invalid screen name" 
//								message:@"Username can only contain letters, numbers and '_'"];
//    } else {
    
    [username_field resignFirstResponder];
    [password_field resignFirstResponder];
	[self saveSettings];
	KYMeetClient *client = [[KYMeetClient alloc] initWithTarget:self action:@selector(accountDidVerify:obj:)];
	[client verify];
//	}

}

- (void) accountDidVerify:(KYMeetClient*)sender obj:(NSObject*)obj;
{
    if (sender.hasError) {
        [sender alert];
    }
    else if ([obj isKindOfClass:[NSDictionary class]]) {
		NSDictionary* dic = (NSDictionary*)obj;
		NSDictionary* usr_info = (NSDictionary*)[dic objectForKey:@"user"];

		User *user = [User userWithJsonDictionary:usr_info]  ;
		
		 //NSLog(@"name : %@",  [usr_info objectForKey:@"name"]);
		 //NSLog(@"id   : %@",  [usr_info objectForKey:@"id"]);
		 //NSLog(@"email : %@", [usr_info objectForKey:@"email"]);
		
		[user updateDB] ;
		[[NSUserDefaults standardUserDefaults] setInteger:user.userId		forKey:@"KYUserId"];
		[[NSUserDefaults standardUserDefaults] setObject:user.screenName    forKey:@"screenName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UINavigationController* nav = [[kaya_meetAppDelegate getAppDelegate].tabBarController.viewControllers objectAtIndex:TAB_SETUP];
        SetupViewController *svc = [nav.viewControllers objectAtIndex:0];
        NSLog(@"login calling initSetupView");
        [svc initSetupView];
        
        [self dismissModalViewControllerAnimated:true];
        [[kaya_meetAppDelegate getAppDelegate] closeLoginView:TAB_CIRCLES];
        
/*        
        // now is the time to refresh circle view because viewDidLoad is already gone
        kaya_meetAppDelegate *kaya_delegate = [kaya_meetAppDelegate getAppDelegate];
        UINavigationController* nav = (UINavigationController*)[kaya_delegate getAppTabController:TAB_CIRCLES];
        CirkleViewController* cvc= (CirkleViewController *)[nav.viewControllers objectAtIndex:0];
        
        [cvc restoreAndLoadCirkles:false];
*/         
	}
}

- (IBAction)next: (id)sender
{
	[password_field becomeFirstResponder];
}

- (IBAction)signup:(id)sender
{
    //NSLog(@"sign up button clicked");
    [self dismissModalViewControllerAnimated:true];
    [[kaya_meetAppDelegate getAppDelegate] closeLoginView:TAB_SETUP];
}

- (void) saveSettings
{
    [[NSUserDefaults standardUserDefaults] setObject:username_field.text forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:username_field.text forKey:@"prevUsername"];
    [[NSUserDefaults standardUserDefaults] setObject:password_field.text forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}


@end
