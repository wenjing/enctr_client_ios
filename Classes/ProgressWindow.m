//
//  SendingWindow.m


#import "ProgressWindow.h"


@implementation ProgressWindow

- (void) show
{
    self.windowLevel = UIWindowLevelAlert;

    [indicator startAnimating];
    self.hidden = false;
    [self makeKeyAndVisible];
}

- (void) hide
{
    self.hidden = true;
    [self resignKeyWindow];
    [indicator stopAnimating];
}

@end
