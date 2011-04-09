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

enum {
    SECTION_ACCOUNT,
    SECTION_USERIMAGE,
    NUM_OF_SECTION,
    SECTION_PROFILE,
    SECTION_CONNECT,
};

enum {
    ROW_USERNAME,
    ROW_EMAIL,
    ROW_PASSWORD,
    NUM_ROWS_ACCOUNT,
};

enum {
    ROW_USERIMAGE,
    NUM_ROWS_USERIMAGE,
};

enum {
    ROW_PHONE,
    ROW_LOCATION,
    ROW_URL,
    NUM_ROWS_PROFILE,
};

enum {
    ROW_FACEBOOK,
    ROW_TWITTER,
    NUM_ROWS_CONNECTION,
};

static int sNumRows[NUM_OF_SECTION] = {
    NUM_ROWS_ACCOUNT,
    NUM_ROWS_USERIMAGE,
//    NUM_ROWS_PROFILE,
//    NUM_ROWS_CONNECTION,
};

static NSString * sSectionHeader [NUM_OF_SECTION] = {
    @"Account",
    @"User Image",
//    @"Profile",
//    @"Connection",
};


@implementation SetupViewController
@synthesize navigation;

#define LABLE_TAG        1
#define TEXTFIELD_TAG    2


- (void)viewDidLoad
{
    [super viewDidLoad];
    user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
    nameField.text  = user.name;
    emailField.text = user.email;
    locationField.text = user.location;
    passwordField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"password" ];
    phoneField.text = (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"SBFormattedPhoneNumber"]; // Will return null in simulator!
 
    navigation = self.navigationController ;
    self.navigationItem.title = @"Account Setup";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
    nameField.text  = user.name;
    emailField.text = user.email;
    locationField.text = user.location;
    passwordField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"password" ];
    phoneField.text = (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"SBFormattedPhoneNumber"]; // Will return null in simulator!
//    user_image
    [user_image setClipsToBounds:YES];
    user_image.layer.cornerRadius = 5.0 ;
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
        return 70;
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
            [as addButtonWithTitle:@"Take Picture "];
            [as addButtonWithTitle:@"Choose Photo "];
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
}

- (void)dealloc {
    [super dealloc];
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

- (IBAction) Save : (id) sender {
    NSLog(@"Saving setup changes");
}

- (void) actionSheet:(UIActionSheet *)as clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (buttonIndex == 0 ) return ;
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:YES];
    //imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
}

@end
