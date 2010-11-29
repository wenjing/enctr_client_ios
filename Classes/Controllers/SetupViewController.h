//
//  SetupViewController.h
//
//  Created by Jun Li on 11/8/10.
//  Copyright 2010 Anova Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "kaya_meetAppDelegate.h"
#import "DBConnection.h"
#import "User.h"


@interface SetupViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableViewController  *controller;
	User  *user ;
	IBOutlet UITableViewCell*	Name;
	IBOutlet UITableViewCell*	Email;
	IBOutlet UITableViewCell*	Password;
	IBOutlet UITableViewCell*	Location;
	IBOutlet UITableViewCell*	Phone;
	IBOutlet UITableViewCell*   Image;
	IBOutlet UITableViewCell*	Facebook;
	IBOutlet UITableViewCell*	Twitter;
	
	IBOutlet UITextField*		nameField;
	IBOutlet UITextField*		emailField;
	IBOutlet UITextField*		passwordField;
	IBOutlet UITextField*		phoneField;
	IBOutlet UITextField*		locationField;
}

- (IBAction) Save   : (id)sender ;
- (IBAction) logout : (id)sender ;

@end
