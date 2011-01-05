//
//  SetupViewController.h
//
//  Created by Jun Li on 11/8/10.
//  Copyright 2010 Anova Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIActionSheet.h>
#import <Foundation/Foundation.h>
#import "DBConnection.h"
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
	
	IBOutlet UITextField*		nameField;
	IBOutlet UITextField*		emailField;
	IBOutlet UITextField*		passwordField;
	IBOutlet UITextField*		phoneField;
	IBOutlet UITextField*		locationField;
	IBOutlet UITextField*		urlField;
	IBOutlet UIImageView*		user_image;
	
	UIImagePickerController*	imgPicker ;
	UINavigationController*		navigation;
}

@property(nonatomic, assign) UINavigationController* navigation;

- (IBAction) Save   : (id)sender ;
- (IBAction) logout : (id)sender ;
-(void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
