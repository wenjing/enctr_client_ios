//
//  SendingWindow.h


#import <UIKit/UIKit.h>


@interface ProgressWindow : UIWindow {
    IBOutlet UIActivityIndicatorView*   indicator;
}

- (void) show;
- (void) hide;

@end
