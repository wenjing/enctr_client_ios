//
//  RegisterViewController.m
//  Cirkle
//
//  Created by Wenjing Chu on 5/25/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIImage+Resize.h"
#import "UserQuery.h"
#import "kaya_meetAppDelegate.h"
// sections
enum {
    SECTION_ACCOUNT,
    SECTION_USERIMAGE,
    NUM_OF_SECTION
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

// section/row #
static int sNumRows[NUM_OF_SECTION] = {
    NUM_ROWS_ACCOUNT,
    NUM_ROWS_USERIMAGE,
};


@implementation RegisterViewController
@synthesize holder;
#define LABLE_TAG        1
#define TEXTFIELD_TAG    2

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [holder release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIImageView *logoBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-bar.png"]];
    self.tableView.tableHeaderView = logoBarView;
    
    holder = [[User alloc] init];
    holder.name = nil;
    holder.email = nil;
    holder.password = nil;
    holder.profileImage = nil;
    
    pickedImageView.image = nil;
    nameField.text  = @"";
    emailField.text = @"";
    passwordField.text = @"";
    user_image.image = [UIImage imageNamed:@"unknown-person.png"];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [holder release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return NUM_OF_SECTION;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sNumRows[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
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

            break;
            
        case SECTION_USERIMAGE:
            if (indexPath.row == ROW_USERIMAGE) {
                cell = Image;
            }
            break;

        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_USERIMAGE) {
        return 57;
    }
    else {
        return 45;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

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

        case SECTION_USERIMAGE:
            
            as = [[UIActionSheet alloc] initWithTitle:nil
                                             delegate:self
                                    cancelButtonTitle:@"Cancel"
                               destructiveButtonTitle:nil
                                    otherButtonTitles:nil];
            as.tag = 1;
            [as addButtonWithTitle:@"Take A Picture "];
            [as addButtonWithTitle:@"Choose A Photo "];
            [as showInView:self.view];
            [as release];
            break;
        default:
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
    }  else {
        [textField resignFirstResponder];
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == passwordField) {
        //post registeration to server
        
        NSLog(@"Registering a new user");
        
        holder.name = [[NSString alloc] initWithString:nameField.text];
        holder.email = [[NSString alloc] initWithString:emailField.text];
        holder.password = [[NSString alloc] initWithString:passwordField.text];
        holder.userId = 0;
        
        //one time use query auto released
        UserQuery *query = [[UserQuery alloc] initWithTarget:self action:@selector(userDidSave:)
                                           releaseAtCallBack:true];
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
                
        [query save:options withObject:holder];
    }
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
        
        [sender clear];
        
    } else {
        User *nuser = [[sender getResults] objectAtIndex:0];
        NSLog(@"userDidSave : %d %@ %@ %@", nuser.userId, nuser.name, nuser.email, nuser.profileImageUrl);
        
        //do auto login
        //first save settings
        [[NSUserDefaults standardUserDefaults] setObject:holder.email forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] setObject:holder.email forKey:@"prevUsername"];
        [[NSUserDefaults standardUserDefaults] setObject:holder.password forKey:@"password"];
        
        [[NSUserDefaults standardUserDefaults] setInteger:nuser.userId forKey:@"KYUserId"];
        //is this used?
        [[NSUserDefaults standardUserDefaults] setObject:nuser.screenName forKey:@"screenName"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //[nuser updateDB];
        
        [sender clear];
        
        [self dismissModalViewControllerAnimated:YES];
        
        //switch to circle view
        [[kaya_meetAppDelegate getAppDelegate] closeRegisterView];

    }
    
}

// basic email validation
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:candidate];
}

- (void) actionSheet:(UIActionSheet *)as clickedButtonAtIndex: (NSInteger)buttonIndex
{
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
