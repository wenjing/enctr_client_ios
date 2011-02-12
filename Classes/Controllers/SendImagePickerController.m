//
//  SendImagePickerController.m

#import "MessageViewController.h"
#import "SendImagePickerController.h"

@implementation SendImagePickerController

@synthesize messageViewController;

- (void)viewDidDisappear:(BOOL)animated 
{
    [messageViewController imagePickerControllerDidDisappear];
}

- (void)dealloc {
    [super dealloc];
}


@end
