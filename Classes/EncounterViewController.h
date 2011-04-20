//
//  EncounterViewController.h
//  Cirkle
//
//  Created by Wenjing Chu on 3/22/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionManager.h"
#import "KYMeetClient.h"
#import "CirklePickerSheet.h"

@interface EncounterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *peerTableView;
	UIActivityIndicatorView *spinner;
	UIButton        *startStopButton;
    UILabel         *titleLabel;
    
    NSMutableArray *postRequests;
	SessionManager	*sessionManager;
	NSMutableArray	*foundPeers;
	
    NSUInteger      hostMode;
    
	UIBarButtonItem *refreshButton;
	UIBarButtonItem *confirmButton;
    
    CirklePickerSheet *picker;
}

@property (nonatomic, retain) SessionManager *sessionManager;
@property (nonatomic, retain) NSMutableArray *foundPeers;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *confirmButton;
@property (nonatomic, retain) IBOutlet UITableView *peerTableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UIButton *startStopButton;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) NSMutableArray *postRequests;
@property (nonatomic, retain) CirklePickerSheet *picker;

-(IBAction) refreshButtonPressed;
-(IBAction) confirmButtonPressed;

- (void)postToServer:(NSMutableDictionary*)postMessage;
- (void)retryPostToServer;

@end
