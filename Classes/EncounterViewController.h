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

@interface EncounterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *peerTableView;
	UIActivityIndicatorView *spinner;
	KYMeetClient *webClient;
	SessionManager	*sessionManager;
	NSMutableArray	*foundPeers;
	//need a reference my own identity or circle
	GKSessionMode	currentMode;
	//may need a timer?
	UIBarButtonItem *refreshButton;
	UIBarButtonItem *confirmButton;
}
@property (nonatomic, retain) KYMeetClient *webClient;
@property (nonatomic, retain) SessionManager *sessionManager;
@property (nonatomic, retain) NSMutableArray *foundPeers;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *confirmButton;
@property (nonatomic, retain) IBOutlet UITableView *peerTableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

-(IBAction) refreshButtonPressed;
-(IBAction) confirmButtonPressed;

- (void)postToServer:(NSMutableDictionary*)postMessage;

@end
