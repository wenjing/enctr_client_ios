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
	User  *user ;
	IBOutlet UITableViewCell*	Name;
	IBOutlet UITableViewCell*	Email;
	IBOutlet UITableViewCell*	Password;
	IBOutlet UITableViewCell*	Location;
	IBOutlet UITableViewCell*	Url;
	IBOutlet UITableViewCell*	Phone;
	IBOutlet UITableViewCell*   Image;
	IBOutlet UITableViewCell*	Facebook;
	IBOutlet UITableViewCell*	Twitter;
	
    IBOutlet UIBarButtonItem*   saveButton;
    
	IBOutlet UITextField*		nameField;
	IBOutlet UITextField*		emailField;
	IBOutlet UITextField*		passwordField;
	IBOutlet UITextField*		phoneField;
	IBOutlet UITextField*		locationField;
	IBOutlet UITextField*		urlField;
	IBOutlet HJManagedImageV*   user_image;
    IBOutlet UIImageView*       pickedImageView;
	UIImagePickerController*	imgPicker ;
	UINavigationController*		navigation;
    User*                       holder;
}

@property(nonatomic, assign) UINavigationController* navigation;
@property(nonatomic, retain) User* holder;

- (IBAction) Save   : (id)sender ;
- (IBAction) logout : (id)sender ;
-(void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
