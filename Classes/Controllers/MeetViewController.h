//
//  MeetViewController.h
//
//  Created by Jun Li on 11/8/10.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <Foundation/Foundation.h>
#import "MeetViewDataSource.h"

@interface MeetViewController : UITableViewController {
	BOOL		  isLoaded         ;
	MeetViewDataSource* meetDataSource;
	CGPoint       contentOffset    ;
	int           tab;
} 
- (void) restoreAndLoadMeets:(BOOL)load;

- (IBAction) postMeet:   (id)sender;
- (IBAction) refreshMeet:(id)sender;

@end
