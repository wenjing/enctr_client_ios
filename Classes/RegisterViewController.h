//
//  RegisterViewController.h
//  Cirkle
//
//  Created by Wenjing Chu on 5/25/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIActionSheet.h>
#import <Foundation/Foundation.h>
#import "DBConnection.h"
#import "HJManagedImageV.h"
#import "User.h"

@interface RegisterViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate> {
    
    IBOutlet UITableViewCell*     Name;
    IBOutlet UITableViewCell*     Email;
    IBOutlet UITableViewCell*     Password;
    IBOutlet UITableViewCell*     Image;
    
    IBOutlet UITextField*         nameField;
    IBOutlet UITextField*         emailField;
    IBOutlet UITextField*         passwordField;
    
    // the current image
    IBOutlet HJManagedImageV*   user_image;
    
    // the picked image, to be updated to
    IBOutlet UIImageView*       pickedImageView;
    
    UIImagePickerController*      imgPicker ;
    User*                       holder;
}
@property(nonatomic, retain) User* holder;

- (BOOL) validateEmail: (NSString *) candidate;

@end
