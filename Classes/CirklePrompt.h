//
//  CirklePrompt.h
//  Cirkle
//
//  Created by Wenjing Chu on 4/20/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CirklePrompt : UIAlertView 
{
    UITextField *textField;
}
@property (nonatomic, retain) UITextField *textField;
@property (readonly) NSString *enteredText;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;

@end
