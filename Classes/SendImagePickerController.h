//
//  SendImagePickerController.h

#import <UIKit/UIKit.h>

@class SendViewController;

@interface SendImagePickerController : UIImagePickerController
{
    MessageViewController* messageViewController;
}

@property(nonatomic, assign) MessageViewController* messageViewController;

@end
