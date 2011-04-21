//
//  CirklePrompt.m
//  Cirkle
//
//  Created by Wenjing Chu on 4/20/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirklePrompt.h"


@implementation CirklePrompt
@synthesize textField;
@synthesize enteredText;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    
    if ((self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil]))
    {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
        [theTextField setBackgroundColor:[UIColor whiteColor]]; 
        [self addSubview:theTextField];
        self.textField = theTextField;
        [theTextField release];
        //CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0); 
        //[self setTransform:translate];
    }
    return self;
}

- (void)show
{
    [textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText
{
    return textField.text;
}

- (void)dealloc
{
    [textField release];
    [super dealloc];
}
/* undocumented method
 [alert addTextFieldWithValue:@"" label:nil];
 
 And the delegate is
 
 - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
 if(buttonIndex==0) // cancel button
 return;
 NSString* text = [alertView textField].text;
 } 
 */
@end
