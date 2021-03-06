//
//  SetupViewController.m
//
//  Created by Jun Li on 11/8/10.
//f
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
    ROW_NAME,
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
/*
static NSString * sSectionHeader [NUM_OF_SECTION] = {
    @"Account",
    @"User Image",
    @"Logout",
//    @"Profile",
//    @"Connection",
};
*/

@implementation SetupViewController
@synthesize navigation;
@synthesize holder;

#define LABLE_TAG        1
#define TEXTFIELD_TAG    2


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSLog(@"setupView did load");
    
    navigation = self.navigationController ;
    self.navigationItem.title = @"Settings";
    
    UIImageView *logoBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-bar.png"]];
    self.tableView.tableHeaderView = logoBarView;
    
    holder = [[User alloc] init];
    
    [passwordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self initSetupView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [holder release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    return nil; //sSectionHeader[section];
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
            if (indexPath.row == ROW_NAME) {
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
                cell = Facebookcell;
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
            if (indexPath.row == ROW_NAME) {
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
            [as addButtonWithTitle:@"Take A Picture "];
            [as addButtonWithTitle:@"Choose A Photo "];
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
                cell = Facebookcell;
            }
            else if (indexPath.row == ROW_TWITTER){
                cell = Twitter;
            }
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

/*
 * textField is current text before the last character is done to it, range is where the current editing is
 * (it could be in the middle of the string, and string is the new char.
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (textField == nameField) {
        return (newLength > 50) ? NO : YES;
    } else if (textField == emailField) {
        return (newLength > 320) ? NO : YES; //RFC2821, RFC2822
    }
        return (newLength > 40) ? NO : YES;
}

// return button hit
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //NSLog(@"textFieldShouldReturn");
    
    if(signupMode) {
        //check required fields are properly filled - one at a time
        UIAlertView *alert=nil;
        
        //name
        NSRange rangea = [nameField.text rangeOfString:@":"];
        NSRange rangeb = [nameField.text rangeOfString:@";"];
        
        if ([nameField.text length] < 3) {
            alert = [[UIAlertView alloc] initWithTitle:@"A name is required" 
                                               message:@"Enter your commonly used name so your friends can recognize you"
                                              delegate:nil 
                                     cancelButtonTitle:@"OK" 
                                     otherButtonTitles:nil];
        }  
        else if (rangea.location != NSNotFound || rangeb.location != NSNotFound) {
            alert = [[UIAlertView alloc] initWithTitle:@"Sorry, names cannot contain colon \":\" or semicolon \";\"" 
                                                       message:@"Enter your commonly used name"
                                                      delegate:nil 
                                             cancelButtonTitle:@"OK" 
                                             otherButtonTitles:nil];
        }
        //email
        else if ([emailField.text length] < 3 || 
            ![self validateEmail:emailField.text]) {
            
            alert = [[UIAlertView alloc] initWithTitle:@"Email address is not in correct format" 
                                               message:@"Check your email field again"
                                              delegate:nil 
                                     cancelButtonTitle:@"OK" 
                                     otherButtonTitles:nil];
        }
        
        //password
        else if ([passwordField.text length] < 6 ||
            [passwordField.text length] > 40) {
            alert = [[UIAlertView alloc] initWithTitle:@"Password should have at least 6 characters and no more than 40" 
                                               message:@"Check your password field again"
                                              delegate:nil 
                                     cancelButtonTitle:@"OK" 
                                     otherButtonTitles:nil];
        }
                
        if (alert !=nil )
        {
            [alert show];
            [alert release];
            
            return NO;
        } else {
            //ok
            self.navigationItem.rightBarButtonItem.enabled = true;
            self.navigationItem.leftBarButtonItem.enabled = true;
        }
    } else {
        //update mode
    //check all fields if anyone has changed
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    
    if ((![user.name isEqualToString:nameField.text]) ||
        (![user.email isEqualToString:emailField.text]) ||
        (![password isEqualToString:passwordField.text])) {
        
        //validate again one at a time
        UIAlertView *alert=nil;
        if (![user.name isEqualToString:nameField.text]) {
            if ([nameField.text length] < 1) {
                alert = [[UIAlertView alloc] initWithTitle:@"A name is required" 
                                                   message:@"Enter your commonly used name so your friends can recognize you"
                                                  delegate:nil 
                                         cancelButtonTitle:@"OK" 
                                         otherButtonTitles:nil];
            } else {
                NSRange rangea = [nameField.text rangeOfString:@":"];
                NSRange rangeb = [nameField.text rangeOfString:@";"];
                if (rangea.location != NSNotFound || rangeb.location != NSNotFound) {
                    alert = [[UIAlertView alloc] initWithTitle:@"Names cannot contain any colon \":\" or semicolon \";\"" 
                                                       message:@"Enter your commonly used name"
                                                      delegate:nil 
                                             cancelButtonTitle:@"OK" 
                                             otherButtonTitles:nil];
                }
            }
        }
        
        else if (![user.email isEqualToString:emailField.text]) {
            if ([emailField.text length] < 3 || 
                ![self validateEmail:emailField.text]) {
                
                alert = [[UIAlertView alloc] initWithTitle:@"Email address is not in correct format" 
                                                   message:@"Check your email field again"
                                                  delegate:nil 
                                         cancelButtonTitle:@"OK" 
                                         otherButtonTitles:nil];
            }
        }
        
        else if (![password isEqualToString:passwordField.text]) {
            if ([passwordField.text length] < 6 ||
                [passwordField.text length] > 40) {
                alert = [[UIAlertView alloc] initWithTitle:@"Password should have at least 6 characters and no more than 40" 
                                                   message:@"Check your password field again"
                                                  delegate:nil 
                                         cancelButtonTitle:@"OK" 
                                         otherButtonTitles:nil];
            }
        }
        
        if (alert !=nil) {
            [alert show];
            [alert release];
            return NO;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = true;
            self.navigationItem.leftBarButtonItem.enabled = true;
        }
    } else {
        if (holder.profileImage==nil) {
            //no change even if user clicked or used keyboard
            self.navigationItem.rightBarButtonItem.enabled = false;
            self.navigationItem.leftBarButtonItem.enabled = false;
        }
    }
    }
    
    [textField resignFirstResponder];
    return YES;
}

// user clicked away - resigned as firstresponder
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //NSLog(@"textFieldDidEndEditing");

}

// password field did change
- (void)textFieldDidChange:(UITextField *)textField
{
    NSLog(@"textFieldDidChange");
    if (textField==passwordField) {
        passwordFieldChanged = YES;
    }
}

// basic email validation
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
    NSLog(@"logout");
    
    // reset uname/passwd/kyuid and prevUsername - forget who I am
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"prevUsername"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"KYUserId"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    kaya_meetAppDelegate *kaya_delegate = [kaya_meetAppDelegate getAppDelegate];
    
    //this portion only for update
    if (!signupMode) {
        // reset users information
        [UserStore clear];

        // reset statistics information
        [[Statistics sharedStatistics] clear];
        
        // delete local DB
        [DBConnection deleteDBCache] ;
        
        //clear up meetview
        //[mc resetMeets];    // push login view
        //kaya_delegate.selectedTab = TAB_MEETS;
        //kaya_delegate.tabBarController.selectedIndex = TAB_MEETS;
        
        //clear up circle view controller data
        UINavigationController* nav = (UINavigationController*)[kaya_delegate getAppTabController:TAB_CIRCLES];
        CirkleViewController* cvc= (CirkleViewController *)[nav.viewControllers objectAtIndex:0];
        [cvc clear];
    }
    
    [self initSetupView];
    
    [kaya_delegate     openLoginView];
    
}

-(void)userDidSave:(UserQuery *)sender
{
    if ([sender hasError]) {
        NSLog(@"userDidSave has error");
        
        //this is a little more complicated - we will notify user and treat it as a cancel
        //sender must make sure nothing ever happened
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry. It did not succeed." 
                                                        message:@"Your email address may be already in use. Check and try again." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        [self initSetupView];
        
    } else {
        User *nuser = [[sender getResults] objectAtIndex:0];
        NSLog(@"userDidSave : %d %@ %@ %@", nuser.userId, nuser.name, nuser.email, nuser.profileImageUrl);
        
        self.navigationItem.rightBarButtonItem.enabled = false;
        self.navigationItem.leftBarButtonItem.enabled = false;
        
        if (signupMode) {
            //do auto login
            //first save settings
            [[NSUserDefaults standardUserDefaults] setObject:holder.email forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setObject:holder.email forKey:@"prevUsername"];
            [[NSUserDefaults standardUserDefaults] setObject:holder.password forKey:@"password"];
            
            NSLog(@"holder: %d %@ %@ %@", nuser.userId, holder.name, holder.email, holder.password);
            
            [[NSUserDefaults standardUserDefaults] setInteger:nuser.userId forKey:@"KYUserId"];
            //is this used?
            [[NSUserDefaults standardUserDefaults] setObject:nuser.screenName forKey:@"screenName"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //[nuser updateDB];
            
            //switch to circle view
            self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:TAB_CIRCLES];
            
        } else {
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
    }
    
    //clear our own data
    holder.name = nil;
    holder.email = nil;
    holder.password = nil;
    holder.profileImage = nil;
    
    [sender clear];

}

- (void)initSetupView {
    NSLog(@"Resetting settings view");
    
    // clear working image
    pickedImageView.image = nil;
    
    // clear holder
    if(holder!=nil) {
        holder.name = nil;
        holder.email = nil;
        holder.password = nil;
        holder.profileImage = nil;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = false;
    self.navigationItem.leftBarButtonItem.enabled = false;

    //if still no user_id, it must be for signup, otherwise you must first login to get here
    uint64_t userId = [[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ];
    if (userId==0) {
        NSLog(@"user id %lld",userId);
        signupMode = YES;
    } else
        signupMode = NO;
    
    if (signupMode) {
        nameField.text  = @"";
        emailField.text = @"";
        passwordField.text = @"";
        user_image.image = [UIImage imageNamed:@"unknown-person.png"];
    } else {
        // reset shown text
        user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
        
        NSLog(@"init: %d %@ %@", user.userId, user.name, user.email);
        nameField.text  = user.name;
        emailField.text = user.email;
        //locationField.text = user.location;
        passwordField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"password" ];
        phoneField.text = (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"SBFormattedPhoneNumber"]; // Will return null in simulator!
    
        // current user_image
        [user_image setClipsToBounds:YES];
        user_image.layer.cornerRadius = 0 ;
    
        NSString *picURL = user.profileImageUrl ;
        if ((picURL != (NSString *) [NSNull null]) && (picURL.length !=0)) {
            user_image.url = [NSURL URLWithString:[picURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            kaya_meetAppDelegate *delg = [kaya_meetAppDelegate getAppDelegate];
            [delg.objMan performSelectorOnMainThread:@selector(manage:) withObject:user_image waitUntilDone:YES];
        } else {
            user_image.image = nil;
        }
    }
    
    passwordFieldChanged = NO;
}

- (IBAction) Cancel:(id)sender {
    [self initSetupView];
}

- (IBAction) Save : (id) sender {
    
    if (signupMode) {
        
        if(![nameField.text isEqualToString:@""] &&
           ![emailField.text isEqualToString:@""] &&
           ![passwordField.text isEqualToString:@""])
        {
            NSLog(@"Registering a new user");
            
            self.navigationItem.rightBarButtonItem.enabled = false;
            self.navigationItem.leftBarButtonItem.enabled = false;
            
            holder.name = [[NSString alloc] initWithString:nameField.text];
            //holder.name = [nameField.text stringByReplacingOccurrencesOfString:@"," withString:@"\,"];
            holder.email = [[NSString alloc] initWithString:emailField.text];
            holder.password = [[NSString alloc] initWithString:passwordField.text];
            holder.userId = 0;
            
            //one time use query auto released
            UserQuery *query = [[UserQuery alloc] initWithTarget:self action:@selector(userDidSave:)
                                               releaseAtCallBack:true];
            NSMutableDictionary *options = [NSMutableDictionary dictionary];
            
            //holder.userId = user.userId;
            //holder.name = @"Bessy Mooo";        
            [query save:options withObject:holder];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Some required field not filled" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        return;
    }
    
    NSLog(@"Saving setup changes");
    
    //check all textfields
    if (![user.name isEqualToString:nameField.text]) {
        holder.name = [[NSString alloc] initWithString:nameField.text];
    }
    
    if (![user.email isEqualToString:emailField.text]) {
        holder.email = [[NSString alloc] initWithString:emailField.text];
    }
    
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    
    if (![password isEqualToString:passwordField.text]) {
        holder.password = [[NSString alloc] initWithString:passwordField.text];
    }
        
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
