//
//  SetupViewController.m
//
//  Created by Jun Li on 11/8/10.
//

#import <QuartzCore/QuartzCore.h>
#import "SetupViewController.h"
#import "kaya_meetAppDelegate.h"
#import "CirkleViewController.h"
#import "Statistics.h"
#import "UIImage+Resize.h"
#import "User.h"
#import "UserQuery.h"

// sections
enum {
    SECTION_ACCOUNT,
    SECTION_USERIMAGE,
    SECTION_LOGOUT,
    NUM_OF_SECTION,
    SECTION_PROFILE,
    SECTION_CONNECT,
};

// account section
enum {
    ROW_USERNAME,
    ROW_EMAIL,
    ROW_PASSWORD,
    NUM_ROWS_ACCOUNT,
};

// user image section
enum {
    ROW_USERIMAGE,
    NUM_ROWS_USERIMAGE,
};

// logout section
enum {
    ROW_LOGOUT,
    NUM_ROWS_LOGOUT,
};

// unused for now
enum {
    ROW_PHONE,
    ROW_LOCATION,
    ROW_URL,
    NUM_ROWS_PROFILE,
};

// unused for now
enum {
    ROW_FACEBOOK,
    ROW_TWITTER,
    NUM_ROWS_CONNECTION,
};

// section/row #
static int sNumRows[NUM_OF_SECTION] = {
    NUM_ROWS_ACCOUNT,
    NUM_ROWS_USERIMAGE,
    NUM_ROWS_LOGOUT,
//    NUM_ROWS_PROFILE,
//    NUM_ROWS_CONNECTION,
};

static NSString * sSectionHeader [NUM_OF_SECTION] = {
    @"Account",
    @"User Image",
    @"Logout",
//    @"Profile",
//    @"Connection",
};


@implementation SetupViewController
@synthesize navigation;
@synthesize holder;

#define LABLE_TAG        1
#define TEXTFIELD_TAG    2


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // fill current user info
    user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
    nameField.text  = user.name;
    emailField.text = user.email;
    locationField.text = user.location;
    passwordField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"password" ];
    phoneField.text = (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"SBFormattedPhoneNumber"]; // Will return null in simulator!
 
    // current user_image
    [user_image setClipsToBounds:YES];
    user_image.layer.cornerRadius = 0 ;
    
    NSString *picURL = user.profileImageUrl ;
    if ((picURL != (NSString *) [NSNull null]) && (picURL.length !=0)) {
        user_image.url = [NSURL URLWithString:[picURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        user_image.oid = [NSString stringWithFormat:@"user_%d",user.userId];
        kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
        [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:user_image waitUntilDone:YES];
    } else {
        user_image.image = nil;
    }

    navigation = self.navigationController ;
    self.navigationItem.title = @"Settings";
    
    holder = [[User alloc] init];
    
    //disable save button
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    //disable cancel button
    self.navigationItem.leftBarButtonItem.enabled = false;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [holder release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    /*
    // when user  comes back, refresh all back to current setting again
    // so leaving the settings view is equivalent of canceling all modifications
    
    user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
    nameField.text  = user.name;
    emailField.text = user.email;
    locationField.text = user.location;
    passwordField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"password" ];
    phoneField.text = (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"SBFormattedPhoneNumber"]; // Will return null in simulator!
    
    // current user_image
    [user_image setClipsToBounds:YES];
    user_image.layer.cornerRadius = 0 ;
    
    NSString *picURL = user.profileImageUrl ;
    if ((picURL != (NSString *) [NSNull null]) && (picURL.length !=0)) {
        user_image.url = [NSURL URLWithString:[picURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        user_image.oid = [NSString stringWithFormat:@"user_%d",user.userId];
        kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
        [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:user_image waitUntilDone:YES];
    } else {
        user_image.image = nil;
    }
     */
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_OF_SECTION;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sNumRows[section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection: (NSInteger)section
{
    return sSectionHeader[section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_USERIMAGE) {
        return 57;
    }
    else {
        return 45;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    UILabel        *label;
    UITextField *text;
    
    switch (indexPath.section) {
        case SECTION_ACCOUNT:
            if (indexPath.row == ROW_USERNAME) {
                cell = Name;
            }
            else if (indexPath.row == ROW_EMAIL){
                cell = Email;
            }
            else {
                cell = Password;
            }
            text = (UITextField*)[cell viewWithTag:TEXTFIELD_TAG];
            text.font = [UIFont systemFontOfSize:16];
            label = (UILabel*)[cell viewWithTag:LABLE_TAG];
            label.font = [UIFont boldSystemFontOfSize:16];
            break;
            
        case SECTION_USERIMAGE:
            if (indexPath.row == ROW_USERIMAGE) {
                cell = Image;
            }
            break;
            
        case SECTION_LOGOUT:
            if (indexPath.row == ROW_LOGOUT) {
                cell = Logout;
            }
            break;
            
        case SECTION_PROFILE:
            if (indexPath.row == ROW_PHONE) {
                cell = Phone;
            }
            else if (indexPath.row == ROW_LOCATION){
                cell = Location;
            }
            else {
                cell = Url;
            }
            text = (UITextField*)[cell viewWithTag:TEXTFIELD_TAG];
            text.font = [UIFont systemFontOfSize:16];
            label = (UILabel*)[cell viewWithTag:LABLE_TAG];
            label.font = [UIFont boldSystemFontOfSize:16];
            break;
            
        default: // SECTION_CONNECTION
            if (indexPath.row == ROW_FACEBOOK) {
                cell = Facebook;
            }
            else if (indexPath.row == ROW_TWITTER){
                cell = Twitter;
            }
            text = (UITextField*)[cell viewWithTag:TEXTFIELD_TAG];
            text.font = [UIFont systemFontOfSize:16];
            break;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UITextField *text ;
    UIActionSheet *as;
    
    switch (indexPath.section) {
        case SECTION_ACCOUNT:
            if (indexPath.row == ROW_USERNAME) {
                cell = Name;
            }
            else if (indexPath.row == ROW_EMAIL){
                cell = Email;
            }
            else {
                cell = Password;
            }
            text = (UITextField*)[cell viewWithTag:TEXTFIELD_TAG];
            [text becomeFirstResponder];
            break;
            
        case SECTION_PROFILE:
            if (indexPath.row == ROW_PHONE) {
                cell = Phone;
            }
            else if (indexPath.row == ROW_LOCATION){
                cell = Location;
            }
            else {
                cell = Url;
            }
             text = (UITextField*)[cell viewWithTag:TEXTFIELD_TAG];
            [text becomeFirstResponder];
            break;
            
        case SECTION_USERIMAGE:
            
            as = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                    cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                    otherButtonTitles:nil];
            as.tag = 1;
            [as addButtonWithTitle:@"Take Picture "];
            [as addButtonWithTitle:@"Choose Photo "];
            [as showInView:navigation.parentViewController.view];
            [as release];
            break;
            
        case SECTION_LOGOUT:
            as = [[UIActionSheet alloc] initWithTitle:nil
                                             delegate:self
                                    cancelButtonTitle:@"Cancel"
                               destructiveButtonTitle:@"Logout"
                                    otherButtonTitles:nil];
            as.tag=2;
            [as showInView:navigation.parentViewController.view];
            [as release];
            break;
            
        default: // SECTION_CONNECTION
            if (indexPath.row == ROW_FACEBOOK) {
                cell = Facebook;
            }
            else if (indexPath.row == ROW_TWITTER){
                cell = Twitter;
            }
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //check which one
    if (( textField == nameField) && (![user.name isEqualToString:textField.text])) {
        holder.name = [[NSString alloc] initWithString:textField.text];
        self.navigationItem.rightBarButtonItem.enabled = true;
        self.navigationItem.leftBarButtonItem.enabled = true;
    }
    else if ((textField == emailField) && (![user.email isEqualToString:textField.text])) {
        holder.email = [[NSString alloc] initWithString:textField.text];
        self.navigationItem.rightBarButtonItem.enabled = true;
        self.navigationItem.leftBarButtonItem.enabled = true;
    }
    else if ((textField == passwordField) && (![user.password isEqualToString:textField.text])){
        //to-do: the comparison doesn't really work - user.password is null not there probably for security
        //so every time user clicks on the password field we think he may have changed it
        holder.password = [[NSString alloc] initWithString:textField.text];
        self.navigationItem.rightBarButtonItem.enabled = true;
        self.navigationItem.leftBarButtonItem.enabled = true;
    }
}

// to-do: user name check?

// to-do: basic validation may be nice
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:candidate];
}

- (void)dealloc {
    [super dealloc];
    
    [holder release];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction) logout : (id) sender {
    
    // reset uname/passwd/kyuid
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"prevUsername"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setInteger:0     forKey:@"KYUserId"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // reset statistics information
    [[Statistics sharedStatistics] clear];

    // delete local DB
    [DBConnection deleteDBCache] ;

    kaya_meetAppDelegate *kaya_delegate = [kaya_meetAppDelegate getAppDelegate];
    MeetViewController *mc = [kaya_delegate getAppMeetViewController] ;
    [mc resetMeets];    // push login view
    //kaya_delegate.selectedTab = TAB_MEETS;
    //kaya_delegate.tabBarController.selectedIndex = TAB_MEETS;
    
    //clear up circle view controller data
    UINavigationController* nav = (UINavigationController*)[kaya_delegate getAppTabController:TAB_CIRCLES];
	CirkleViewController* cvc= (CirkleViewController *)[nav.viewControllers objectAtIndex:0];
    [cvc clear];
    
    [kaya_delegate     openLoginView];
    
}

-(void)userDidSave:(UserQuery *)sender
{
    if ([sender hasError]) {
        NSLog(@"userDidSave has error");
        
        //this is a little more complicated - we will notify user and treat it as a cancel
        //sender must make sure nothing ever happened
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops, unexpected problem. Please try later." 
                                                        message:nil 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        [self Cancel:self];
        
    } else {
        User *nuser = [[sender getResults] objectAtIndex:0];
        NSLog(@"userDidSave : %d %@ %@ %@", nuser.userId, nuser.name, nuser.email, nuser.profileImageUrl);
        
        //clear our own data
        holder.name = nil;
        holder.email = nil;
        holder.password = nil;
        holder.profileImage = nil;
        
        self.navigationItem.rightBarButtonItem.enabled = false;
        self.navigationItem.leftBarButtonItem.enabled = false;
        
        //i'm not clearing the picked image
        
        //Notify user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Saved" 
                                                        message:nil 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [sender clear];

}

- (IBAction) Cancel:(id)sender {
    NSLog(@"Canceling setup changes");
    
    // clear working image
    pickedImageView.image = nil;
    
    // clear holder
    holder.name = nil;
    holder.email = nil;
    holder.password = nil;
    holder.profileImage = nil;
    
    self.navigationItem.rightBarButtonItem.enabled = false;
    self.navigationItem.leftBarButtonItem.enabled = false;
    
    // reset shown text
    user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
    nameField.text  = user.name;
    emailField.text = user.email;
    locationField.text = user.location;
    passwordField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"password" ];
    phoneField.text = (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"SBFormattedPhoneNumber"]; // Will return null in simulator!
    
    // current user_image
    [user_image setClipsToBounds:YES];
    user_image.layer.cornerRadius = 0 ;
    
    NSString *picURL = user.profileImageUrl ;
    if ((picURL != (NSString *) [NSNull null]) && (picURL.length !=0)) {
        user_image.url = [NSURL URLWithString:[picURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        user_image.oid = [NSString stringWithFormat:@"user_%d",user.userId];
        kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
        [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:user_image waitUntilDone:YES];
    } else {
        user_image.image = nil;
    }
}

- (IBAction) Save : (id) sender {
    NSLog(@"Saving setup changes");
    
    if (holder.name!=nil || 
        holder.email!=nil ||
        holder.password!=nil || 
        holder.profileImage!=nil) {
        
        //one time use query auto released
        UserQuery *query = [[UserQuery alloc] initWithTarget:self action:@selector(userDidSave:)
                                           releaseAtCallBack:true];
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        
        holder.userId = user.userId;
        //holder.name = @"Bessy Mooo";        
        [query save:options withObject:holder];
    }
    
}

- (void) actionSheet:(UIActionSheet *)as clickedButtonAtIndex: (NSInteger)buttonIndex
{
    // photo pick
    if (as.tag == 1) {
        if (buttonIndex == 0 ) 
            return ;
        
        if ( imgPicker==nil ) {
            imgPicker = [[UIImagePickerController alloc] init];
            imgPicker.allowsEditing = YES;
            imgPicker.delegate = self;
        }
        if(buttonIndex == 1) {
            imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        [self presentModalViewController:imgPicker animated:YES];
    }
    // logout
    else if (as.tag == 2) {
        if (buttonIndex == 1) //cancel
            return;
        [self logout:self]; //logout
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissModalViewControllerAnimated:YES];
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    if (image!=nil) {
        holder.profileImage = [[image resizedImage:CGSizeMake(245,245) interpolationQuality:kCGInterpolationHigh] retain];
    
        pickedImageView.image = [holder.profileImage thumbnailImage:47 
                                        transparentBorder:0 
                                             cornerRadius:0 
                                     interpolationQuality:kCGInterpolationHigh];
        
        self.navigationItem.rightBarButtonItem.enabled = true;
        self.navigationItem.leftBarButtonItem.enabled = true;

    }
    // else no change
}

@end
