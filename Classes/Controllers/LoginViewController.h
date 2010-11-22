//
//  LoginViewController.h
//
//  Created by Jun Li on 10/27/10.
//  Copyright 2010 Anova Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>  {
	IBOutlet UIView*		view ;
    IBOutlet UITextField*	username_field;
	IBOutlet UITextField*   password_field;
}

- (IBAction) done:(id)sender ;
- (IBAction) next:(id)sender ;
- (void) saveSettings;
@end
