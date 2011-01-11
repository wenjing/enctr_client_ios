//
//  MeetViewController.h
//
//  Created by Jun Li on 11/8/10.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MeetViewDataSource.h"
#import "AccelerometerFilter.h"
#import "MBProgressHUD.h"

@interface MeetViewController : UITableViewController<UIAccelerometerDelegate> {
	BOOL			isLoaded       ;
	MeetViewDataSource* meetDataSource;
	CGPoint			contentOffset  ;
	HighpassFilter          *filter;
	int				tab;
	CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject;
	
	IBOutlet  UISegmentedControl *typeSelector;
	MBProgressHUD	*HUD  ;
} 

@property (readwrite) CFURLRef soundFileURLRef;
@property (readonly)    SystemSoundID   soundFileObject;

- (void) restoreAndLoadMeets:(BOOL)load;
- (void) resetMeets;
- (IBAction) postMeet:   (id)sender;
- (IBAction) refreshMeet:(id)sender;

- (void) typeSelected:(id)sender;
@end
