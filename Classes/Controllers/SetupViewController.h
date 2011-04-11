//
//  SetupViewController.h
//
//  Created by Jun Li on 11/8/10.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIActionSheet.h>
#import <Foundation/Foundation.h>
#import "DBConnection.h"
#import "HJManagedImageV.h"
#import "User.h"


@interface SetupViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate> {
    
    // current active user info
	User*                       user ;
    
	IBOutlet UITableViewCell*	Name;
	IBOutlet UITableViewCell*	Email;
	IBOutlet UITableViewCell*	Password;
    IBOutlet UITableViewCell*	Logout;
	IBOutlet UITableViewCell*	Location;
	IBOutlet UITableViewCell*	Url;
	IBOutlet UITableViewCell*	Phone;
	IBOutlet UITableViewCell*   Image;
	IBOutlet UITableViewCell*	Facebook;
	IBOutlet UITableViewCell*	Twitter;
    
	IBOutlet UITextField*		nameField;
	IBOutlet UITextField*		emailField;
	IBOutlet UITextField*		passwordField;
	IBOutlet UITextField*		phoneField;
	IBOutlet UITextField*		locationField;
	IBOutlet UITextField*		urlField;
    
    // the current image
	IBOutlet HJManagedImageV*   user_image;
    
    // the picked image, to be updated to
    IBOutlet UIImageView*       pickedImageView;
    
	UIImagePickerController*	imgPicker ;
	UINavigationController*		navigation;
    
    // holder for updated information
    User*                       holder;
    BOOL                        passwordFieldChanged;
    BOOL                        signupMode;
}

@property(nonatomic, assign) UINavigationController* navigation;
@property(nonatomic, retain) User* holder;

- (IBAction) Save   : (id)sender ;
- (IBAction) Cancel : (id)sender ;
- (IBAction) logout : (id)sender ;
- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)textFieldDidChange:(UITextField *)textField;

@end
