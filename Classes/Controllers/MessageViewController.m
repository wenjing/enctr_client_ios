//
//  SendViewController.m


#import <QuartzCore/QuartzCore.h>
#import "MessageViewController.h"
#import "kaya_meetAppDelegate.h"
#import "SendImagePickerController.h"
#import "MessageView.h"
#import "REString.h"
#import "UIImage+Resize.h"

#define kShowAnimationkey   @"showAnimation"
#define kHideAnimationKey   @"hideAnimation"

#define GPS_BUTTON_INDEX    2
#define CAMERA_BUTTON_INDEX 3

@implementation MessageViewController

@synthesize navigation;
@synthesize selectedPhoto, picture;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    text.font           = [UIFont systemFontOfSize:16];
    self.view.hidden    = true;
	self.view.frame = [[UIScreen mainScreen] applicationFrame];
	
    textRange.location  = [text.text length];
    textRange.length    = 0;
    
    return self;
}

- (void)dealloc 
{
    [selectedPhoto release];
	[super dealloc];
}


- (void)edit
{
	if ( isReplyMessage ) {
		self.navigationItem.title = @"Reply";
	}else if ( isInviteMessage ) {
		self.navigationItem.title = @"Invite";
	}else {
		self.navigationItem.title = @"Message";
	}
	
    [navigation.view addSubview:self.view];
    [messageView setCharCount];
    [messageView setNeedsLayout];
    [messageView setNeedsDisplay];
    
    self.view.hidden = false;
    didPost = false;
	
    if (isReplyMessage && [recipient.text length] == 0) {
        [recipient becomeFirstResponder];
    }else if (isInviteMessage ) {
		[recipient becomeFirstResponder];
    } else {
        [text becomeFirstResponder];
    }
    text.selectedRange = textRange;
    
    CATransition *animation = [CATransition animation];
 	[animation setDelegate:self];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setDuration:0.3];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.view layer] addAnimation:animation forKey:kShowAnimationkey];
}


- (void)editWithMessage:(NSString*)message
{
    text.text = message;
    [self edit];
}

- (void)postTo:(KYMeet*)mt
{
	isReplyMessage = false;
	isInviteMessage = false;
    [messageView editMessage:mt];
    [self edit];
}

- (void)replyTo:(KYMeet*)mt ofChatId:(uint32_t)cid
{
	isReplyMessage = true;
	[messageView editReply:mt ofChatId:cid];
	[self edit];
}

- (void)inviteTo:(KYMeet *)mt
{
	isInviteMessage = true;
	text.text = [NSString stringWithFormat:@"Great to meet you on Kaya\nTo keep in touch, please join our Live Social Network\n -%@", mt.user.name];
    textRange.location = [text.text length];
    textRange.length = 0;
	recipient.text = @"";
	[messageView editInvite:mt];
	
	[self edit];
}

- (void)saveMessage
{
	[messageView saveMessage];
}

- (IBAction) close: (id) sender
{
    [recipient resignFirstResponder];
    [text resignFirstResponder];
    self.view.hidden = true;
    if (isInviteMessage) text.text = @"" ;
	CATransition *animation = [CATransition animation];
 	[animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self.view layer] addAnimation:animation forKey:kHideAnimationKey];
}

- (void)cancel: (id)sender
{
    if (connection) {
        [connection cancel];
        [connection autorelease];
        connection = nil;
    }
    [progressWindow hide];
}

- (UIImage*)modifyPhoto:(UIImage *)image
{
 /*   float width  = image.size.width;
    float height = image.size.height;
    float scale;
    
    if (width > height) {
        scale = 640.0 / width;
    }
    else {
        scale = 480.0 / height;
    } 
	
	return scale >= 1.0 ? image : [image  scaleAndRotateImage:640]; */
	
	return [image resizedImage:CGSizeMake(245,245) interpolationQuality:kCGInterpolationHigh];
}

- (void)updateMessage
{
    KYMeetClient *client = [[KYMeetClient alloc] initWithTarget:self action:@selector(sendDidSucceed:obj:)];
	
	[client postMessage:text.text toMeetId:messageView.InReplyToMeetId 
								  toChatId:messageView.isReplyFlag?messageView.InReplyToChatId:-1
								 photoData:selectedPhoto ];
    [progressWindow show];
    connection = client;
}


//
// May need to add address check 
//
- (void)inviteMessage
{
	uint32_t userId = [[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ];
	KYMeetClient *client = [[KYMeetClient alloc] initWithTarget:self action:@selector(sendDidSucceed:obj:)];
	[client postInvite:recipient.text
			  byUserId:userId
			  byMeetId:messageView.InReplyToMeetId 
			custMessage:text.text ];
    [progressWindow show];
    connection = client;
}


- (IBAction) send: (id) sender
{
    int length = [text.text length];
    if (length == 0) {
        sendButton.enabled = false;
        return;
    }
        
    //[progressWindow show];

	if ( isInviteMessage ) {
		[self inviteMessage] ;
	} else {
		[self updateMessage] ;
	}
	/* need to seperate photo upload and message upload seperately
	if (selectedPhoto) {
        [self performSelector:@selector(uploadPhoto) withObject:nil afterDelay:0.1];
    }
    else {
        [self updateMessage];
    }
	 */
}

//
// PicClient delegate
//
- (void)KYmeetPicClientDidPost:(KYMeetClient*)sender mediaId:(NSString*)mediaId
{
    self.selectedPhoto = nil;
    photoButton.style = UIBarButtonItemStyleBordered;

    text.text = [NSString stringWithFormat:@"%@ http://alink/%@", text.text, mediaId];
    int length = [text.text length];
    if (length > 140) {
        sendButton.enabled = false;
        [progressWindow hide];
    }
    else {
        [self send:self];
    }
    [sender release];
    connection = nil;
}

- (void)KYMeetPicClientDidFail:(KYMeetClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    [[kaya_meetAppDelegate getAppDelegate] alert:error message:detail];
    [sender release];
    connection = nil;
    [progressWindow hide];
}


//
// Photo Uploading
//
- (void)showImagePicker:(BOOL)hasCamera
{
    SendImagePickerController *picker = [[[SendImagePickerController alloc] init] autorelease];
	picker.allowsEditing = YES;
    picker.messageViewController = self;
    picker.delegate = self;
    if (hasCamera) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [navigation presentModalViewController:picker animated:YES];
    
}

- (IBAction) photos:(id)sender
{
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    if (selectedPhoto == nil && hasCamera == false) {
        [self showImagePicker:false];
        return;
    }
    
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil];
    
    if (selectedPhoto) {
        [as addButtonWithTitle:@"Cancel"];
        as.destructiveButtonIndex = [as numberOfButtons] - 1;
    }
    
    if (hasCamera) {
        [as addButtonWithTitle:@"Take Photo"];
    }
    
    [as addButtonWithTitle:@"Choose Photo"];
    [as addButtonWithTitle:@"Cancel"];
    as.cancelButtonIndex = [as numberOfButtons] - 1;
    
    [as showInView:navigation.parentViewController.view];
    [as release];
}

- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as.cancelButtonIndex == buttonIndex) {
        return;
    }
    else if (as.destructiveButtonIndex == buttonIndex) {
        self.selectedPhoto = nil;
        photoButton.style = UIBarButtonItemStyleBordered;
        return;
    }
    
    NSString *title = [as buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Take Photo"]) {
        [self showImagePicker:true];
    }
    else {
        [self showImagePicker:false];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // do nothing here
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissModalViewControllerAnimated:YES];
	UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.selectedPhoto = [self modifyPhoto:image] ;
	self.picture.image = [self.selectedPhoto thumbnailImage:50 
										  transparentBorder:2 
											   cornerRadius:5.0 
									   interpolationQuality:kCGInterpolationHigh];
	
	/*CGSize itemSize  = CGSizeMake(50,50);
	UIGraphicsBeginImageContext(itemSize);
	CGRect imageRect = CGRectMake(0.0,0.0,itemSize.width, itemSize.height);
	[self.selectedPhoto drawInRect:imageRect];
	self.picture.image = UIGraphicsGetImageFromCurrentImageContext();
	 UIGraphicsEndImageContext();*/
    photoButton.style = UIBarButtonItemStyleDone;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [navigation dismissModalViewControllerAnimated:YES];
}

- (void)showKeyboard
{
    [text becomeFirstResponder];
     text.selectedRange = textRange;
}

- (void)imagePickerControllerDidDisappear
{
    [self performSelector:@selector(showKeyboard) withObject:nil afterDelay:0.1];
}

- (void)sendDidSucceed:(KYMeetClient*)sender obj:(NSObject*)obj;
{
    [progressWindow hide];
//	[connection autorelease];
    connection = nil;
    if (sender.hasError) {
        [sender alert];
        return;
    }

/* To add reaction to Application
 
    NSDictionary *dic = nil;
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        dic = (NSDictionary*)obj;    
    }
   
    if (dic) {
        kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
		[appDelegate sendMessageDidSucceed:dic];
    }       
 */
    text.text = @"";
    messageView.InReplyToMeetId = 0;
	messageView.InReplyToChatId = 0;
	messageView.isReplyFlag  = false;
	messageView.isInviteFlag = false;
    textRange.location = 0;
    textRange.length = 0;
    [self close:self];
	selectedPhoto = nil;
	picture.image = nil;
    didPost =  true ;
}

- (void)checkProgressWindowState
{
    if (connection == nil) {
        [progressWindow hide];
    }
}

//
// UITextViewDelegate
//
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    textRange = text.selectedRange;
}

- (void)textViewDidChange:(UITextView *)textView
{
    textRange = text.selectedRange;
    [messageView setCharCount];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    recipientIsFirstResponder = false;
}

//
// UITextFieldDelegate
//
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    recipientIsFirstResponder = true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([str length] == 0) {
        sendButton.enabled = false;
    }
    else {
        int length = 140 - [text.text length];
        if (length == 140) {
            sendButton.enabled = false;
        }
        else if (length < 0) {
            sendButton.enabled = false;
        }
        else {
            sendButton.enabled = true;
        }
    }
    return true;
}

//
// CAAnimationDelegate
//
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished 
{
    CATransition *t = (CATransition*)animation;
    if (t.type == kCATransitionMoveIn) {
		sendButton.enabled = false;
		[messageView performSelector:@selector(setCharCount) withObject:nil afterDelay:0.5];
    }
    else {
        [self.view removeFromSuperview];
        
        kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate.window makeKeyWindow];
        
        if (finished && didPost) {
            kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate messageViewAnimationDidFinish];
        }
    }
}

// people pick
// The application only shows the phone, email, and birthdate information of the selected contact.

-(void)showPeoplePickerController
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	// Display only a person's phone, email, and birthdate
	NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], 
							  [NSNumber numberWithInt:kABPersonEmailProperty],nil];
	
	picker.displayedProperties = displayedItems;
	picker.navigationItem.title = @"select to invite";
	// Show the picker 
	[self presentModalViewController:picker animated:YES];
    [picker release];	
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	return YES ;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	if (property == kABPersonEmailProperty) {
		id value = [(id)ABRecordCopyValue(person,property) autorelease];
		CFIndex idx = ABMultiValueGetIndexForIdentifier((ABMultiValueRef)value,identifier);
		NSString *email = [(NSString*)ABMultiValueCopyValueAtIndex((ABMultiValueRef)value, idx) autorelease];

		recipient.text = [NSString stringWithFormat:@"%@ %@",(NSString*)email,recipient.text] ;
		sendButton.enabled = true;
		[ self dismissModalViewControllerAnimated:YES ];
	}
	return NO;
}

// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
	[self dismissModalViewControllerAnimated:YES];
}


@end
