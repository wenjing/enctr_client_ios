//
//  SetupViewController.m
//
//  Created by Jun Li on 11/8/10.
//  Copyright 2010 Anova Solutions Inc. All rights reserved.
//

#import "SetupViewController.h"

enum {
	SECTION_ACCOUNT,
	SECTION_PROFILE,
	SECTION_CONNECT,
	NUM_OF_SECTION,
};

enum {
	ROW_USERNAME,
	ROW_EMAIL,
	ROW_PASSWORD,
	NUM_ROWS_ACCOUNT,
};

enum {
	ROW_PHONE,
	ROW_URL,
	ROW_LOCATION,
	NUM_ROWS_PROFILE,
};

enum {
	ROW_FACEBOOK,
	ROW_TWITTER,
	NUM_ROWS_CONNECTION,
};

static int sNumRows[NUM_OF_SECTION] = {
	NUM_ROWS_ACCOUNT,
	NUM_ROWS_PROFILE,
	NUM_ROWS_CONNECTION,
};

static NSString * sSectionHeader [NUM_OF_SECTION] = {
	@"Account",
	@"Profile",
	@"Connection",
};

@implementation SetupViewController

#define LABLE_TAG		1
#define TEXTFIELD_TAG	2


- (void)viewDidLoad
{
	[super viewDidLoad];
	user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
	nameField.text  = user.name;
	emailField.text = user.email;
	locationField.text = user.location;
	passwordField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"password" ];
	phoneField.text = (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"SBFormattedPhoneNumber"]; // Will return null in simulator!
 
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    UITableViewCell *cell;
    UILabel		*label;
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
		
        case SECTION_PROFILE:
			if (indexPath.row == ROW_PHONE) {
                cell = Phone;
            }
			else if (indexPath.row == ROW_LOCATION){
				cell = Location;
			}
            else {
                cell = Image;
				text = (UITextField*)[cell viewWithTag:TEXTFIELD_TAG];
				text.font = [UIFont systemFontOfSize:16];
				break;
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
                cell = Image;
				break;
            }
             text = (UITextField*)[cell viewWithTag:TEXTFIELD_TAG];
            [text becomeFirstResponder];
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
	// delete local DB
	[DBConnection deleteDBCache] ;
	
	// reset uname/passwd/kyuid
	[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"prevUsername"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
	[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"KYsessionToken"];
	[[NSUserDefaults standardUserDefaults] setInteger:0	 forKey:@"KYUserId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	
	// push login view
	
	[[kaya_meetAppDelegate getAppDelegate] 	openLoginView];
}

- (IBAction) Save : (id) sender {
}

@end
