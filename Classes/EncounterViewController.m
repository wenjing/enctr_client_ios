//
//  EncounterViewController.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/22/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "EncounterViewController.h"
#import "EncounterView.h"
#import "EncounterCell.h"
#import "User.h"
#import "StringUtil.h"
#import "kaya_meetAppDelegate.h"
#import "CirkleViewController.h"
#import "CirkleSummary.h"

@implementation EncounterViewController
@synthesize sessionManager;
@synthesize foundPeers;
@synthesize refreshButton;
@synthesize confirmButton;
@synthesize peerTableView;
@synthesize spinner;
@synthesize postRequests;
@synthesize picker;
@synthesize startStopButton;
@synthesize titleLabel;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}

// Create a color of blue that mimics the official gray highlighting
- (UIColor *) sysBlueColor:(float) percent {
    float red = percent * 255.0f;
    float green = (red + 20.0f) / 255.0f;
    float blue = (red + 45.0f) / 255.0f;
    if (green > 1.0) green = 1.0f;
    if (blue > 1.0f) blue = 1.0f;
    return [UIColor colorWithRed:percent green:green blue:blue alpha:1.0f];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Other initialization moved to tab selected	
    postRequests = [[NSMutableArray alloc] init];
    
    // Initialization code
    [self.view setAlpha:0.9];
    [self.view setBackgroundColor:[self sysBlueColor:0.6f]];
    
    // Add title
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 320.0f, 32.0f)];
    titleLabel.text = @"Open Encounter";
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    
    [self.view addSubview:titleLabel];
    
    // Add button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setFrame:CGRectMake(60.0f, 318.0f, 200.0f, 32.0f)];
    
    [button setBackgroundImage:[[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
    
    //[button setTitle:@"Start" forState: UIControlStateHighlighted];
    [button setTitle:@"Start" forState: UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    
    [button addTarget:self action:@selector(buttonStartStopPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    startStopButton = button;
    
    [spinner stopAnimating];
    
    // Add border for the table
    CGRect bounds = CGRectMake(10.0f, 40.0f, 300.0f, 310.0f - 48.0f);
    UIView *borderView = [[UIView alloc] initWithFrame:bounds];
    [borderView setBackgroundColor:[self sysBlueColor:0.4f]];
    borderView.layer.cornerRadius = 5;
    
    [self.view addSubview:borderView];
    [borderView release];
    
    //[self.peerTableView setFrame:CGRectInset(bounds, 4.0f, 4.0f)];
    
    self.peerTableView = [[UITableView alloc] initWithFrame:CGRectInset(bounds, 4.0f, 4.0f)
                style:UITableViewStylePlain];
    self.peerTableView.backgroundColor = [UIColor whiteColor];
    self.peerTableView.delegate = self;
    self.peerTableView.dataSource = self;

    self.peerTableView.layer.cornerRadius = 5;
    
    [self.peerTableView reloadData];
    [self.view addSubview:self.peerTableView];
    [self.view bringSubviewToFront:self.peerTableView];
}

- (void) buttonStartStopPressed:(id)sender
{
    if (![spinner isAnimating]) {
        // start the session Manager
        NSLog(@"Start is pressed");
        
        UIButton *button = (UIButton *)sender;
        [button setTitle:@"Stop" forState:UIControlStateNormal];
        
        [sessionManager startSession];
        [spinner startAnimating];
        
        
    } else {
        // stop the session Manager
        NSLog(@"Stop is pressed");
        
        UIButton *button = (UIButton *)sender;
        [button setTitle:@"Start" forState:UIControlStateNormal];
        if (sessionManager!=nil)
            [sessionManager stopSession];
        [spinner stopAnimating];
        confirmButton.enabled = YES;
    }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	// when this view is unloaded, we treat this as a cancel
	[foundPeers removeAllObjects];
	[foundPeers release];
	[sessionManager stopSession];
	[sessionManager release];
	//Client is working asynchronously, do not cancel nor release
	[refreshButton release];
	[confirmButton release];
	[spinner release];
    [picker release];
    [startStopButton release];
    [titleLabel release];
    [peerTableView release];
}


- (void)dealloc {
	[foundPeers removeAllObjects];
	[foundPeers release];
	[sessionManager stopSession];
	[sessionManager release];
	
	[refreshButton release];
	[confirmButton release];
	[spinner release];
    [startStopButton release];
    [titleLabel release];
    [peerTableView release];
    
    //dealloc calls cancel
    [postRequests removeAllObjects];
    [postRequests release];
    
    [picker release];
    
    [super dealloc];
}

-(IBAction) refreshButtonPressed {

	//stop session
	if (sessionManager) {
		[sessionManager stopSession];
		self.sessionManager = nil;
	}
	
	//update view
	NSMutableArray* indexPathsDelete = [NSMutableArray array];
	NSInteger rows = [self.foundPeers count];
	
	[self.peerTableView beginUpdates];
	
	for (int i=0; i<rows; i++) {
		[indexPathsDelete addObject: [NSIndexPath indexPathForRow:i inSection:0]];
	}	
	[foundPeers removeAllObjects];
	[self.peerTableView deleteRowsAtIndexPaths:indexPathsDelete  
							  withRowAnimation:UITableViewRowAnimationLeft];
	
	User *user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
	
    //to-do: have user customizable tag line
    NSString *identity = [NSString stringWithFormat:@"%@:%d:Hello!",user.name,user.userId];
    
	[foundPeers addObject:identity];
	
	NSArray* indexPathsInsert = [NSArray arrayWithObjects:
								 [NSIndexPath indexPathForRow:0 inSection:0], nil];
	
	[self.peerTableView insertRowsAtIndexPaths:indexPathsInsert 
							  withRowAnimation:UITableViewRowAnimationRight];
	[self.peerTableView endUpdates];
	
	
	//start a new session
	sessionManager = [[SessionManager alloc] initWithDelegate:self];
	
	//to-do: change mode as our identity changes
	sessionManager.sessionMode = GKSessionModePeer;
	
    sessionManager.displayName = identity;
    
	[sessionManager startSession];
	
	confirmButton.enabled = YES;
	[spinner startAnimating];
}

-(IBAction) confirmButtonPressed {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New encounter" 
													message:@"confirmed"
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];

	//stop session
	if (sessionManager) {
		[sessionManager stopSession];
		self.sessionManager = nil;
	}
	[spinner stopAnimating];
    [startStopButton setTitle:@"Completed" forState:UIControlStateNormal];
    startStopButton.enabled = NO;
	
    [titleLabel setText:@"New encounter completed."];
    
	NSMutableDictionary *param = [NSMutableDictionary dictionary];
	NSString* query = [foundPeers componentsJoinedByString:@","];
	
	[param setObject:query forKey:@"devs"];
	
	[param setObject:[foundPeers objectAtIndex:0] forKey:@"user_dev"];
	
	[param setObject:@"0" forKey:@"collision"];
	
	[self postToServer:param];
	
	confirmButton.enabled = NO;
}

#pragma mark -
#pragma mark kaya_meetAppDelegate TabBarController Delegate Methods
- (void)didLeaveTab:(UINavigationController*)navigationController
{
	NSLog(@"encounter tab de-selected");
	// when this view is deselected, we treat this as a cancel
	[foundPeers removeAllObjects];
	[foundPeers release];
	[sessionManager stopSession];
	[sessionManager release];
	//Client is working asynchronously, do not cancel nor release
	[spinner stopAnimating];
    
}

- (void)didSelectTab:(UINavigationController*)navigationController
{
	NSLog(@"encounter tab selected");
	User *user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
	//default to personal identity
    NSString *identity = [NSString stringWithFormat:@"%@:%d:Hello!",user.name,user.userId];
    
	foundPeers = [[NSMutableArray alloc] initWithObjects:identity, nil];
	
	sessionManager = [[SessionManager alloc] initWithDelegate:self];
	
	//to-do: change mode as our identity changes
	sessionManager.sessionMode = GKSessionModePeer;
    sessionManager.displayName = identity;
    
	//Client may be working, don't set it to nil here
	
	//[sessionManager startSession];
	//confirmButton.enabled = YES;
	[self.peerTableView reloadData];
	//[spinner startAnimating];
	
}

#pragma mark -
#pragma mark KYMeetClient Methods

- (void)postToServer:(NSMutableDictionary *)postMessage {
	//the client object is created on the spot
    
	KYMeetClient *postClient = [[KYMeetClient alloc] initWithTarget:self action:@selector(encounterDidPost:obj:)];
	
	kaya_meetAppDelegate *del = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
	
	// meet date
	time_t now;
	time(&now);
	[postMessage setObject:[NSString dateString:now] forKey:@"time"];
	
	// location 
	[postMessage setObject:[NSString stringWithFormat:@"%lf",del.latitude]  forKey:@"lat" ];
	[postMessage setObject:[NSString stringWithFormat:@"%lf",del.longitude] forKey:@"lng"];
	[postMessage setObject:[NSString stringWithFormat:@"%f", del.lerror]    forKey:@"lerror"];
	
    // retain the postMessage dictionary
    postClient.postParams = postMessage;
    
    // retain the Client
    [postClient retain];
    [postRequests addObject:postClient];
    
	NSLog(@"postToServer sending mpost to server");
	// post meet to server
    [postClient postMeet:postMessage];
	
}

// Callback delgate method
- (void)encounterDidPost:(KYMeetClient*)sender obj:(NSObject*)obj
{
    // Look for the client
    NSEnumerator *enumerator = [postRequests objectEnumerator];
    KYMeetClient *client = nil;
    
    while ((client = [enumerator nextObject])) {
        if (client == sender) {
            //NSLog(@"encounterDidPost found the postClient");
            
            break;
        }
    }
    
    if (client == nil) {
        NSLog(@"Internal Error - encounterDidPost could not find the client!");
        return;
    }

    // For unhandled errors - we report and give up
    if (sender.hasError && 
        (sender.errorCode.domain != NSURLErrorDomain ||
         sender.errorCode.code != NSURLErrorNotConnectedToInternet)) {
        
            // we alert the user and give up
            NSLog(@"encounterDidPost post send error code: %@", sender.errorCode);
        
            [sender alert];
            return;
        }
    
    if (client) {
        if (client.hasError && 
            client.errorCode.domain == NSURLErrorDomain &&
            client.errorCode.code == NSURLErrorNotConnectedToInternet) {
            //prepare for retry
            //NSLog(@"Network not available at this time - we will retry later");
            client.toBeRetried = true;
            
            //Don't bother user
            /*
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The network appears not available" 
                                                            message:@"This encounter will be recorded when network does become available later"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            */
        } else {
            //remove
            [postRequests removeObject:client];
            
            //Don't tell user
            /*
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New encounter" 
                                                            message:@"in your circles"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
             */
        }
    }
}

- (void)retryPostToServer {
    // Look for the client
    //NSEnumerator *enumerator = [postRequests objectEnumerator];
    KYMeetClient *client;
    NSInteger count=0;
    NSMutableArray *retryList = [NSMutableArray array];
    
    //find all to be retried
    for (client in postRequests) {
        if (client.toBeRetried) {
            [retryList addObject:client];
        }
    }
    
    [postRequests removeObjectsInArray:retryList];
    
    for (client in retryList) {
        //to avoid depdency on client behavior, create a new client
        KYMeetClient *postClient = [[KYMeetClient alloc] initWithTarget:self action:@selector(encounterDidPost:obj:)];
        
        // copy the postMessage dictionary
        postClient.postParams = client.postParams;
        
        // add the new client to list
        [postRequests addObject:postClient];
        
        // post meet to server
        [postClient postMeet:postClient.postParams];
        
        count++;
    }
    
    [retryList removeAllObjects];

    NSLog(@"retryPostToServer done with %d posts retried", count);
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.foundPeers count];
}

/* allow selecting all rows */
 - (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	 /*NSUInteger row = [indexPath row];
	 if (row == 0) {
		 return nil;
	 }*/
	 return indexPath;
 }


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *peerTableIdentifier = @"PeerTableIdentifier";
	NSUInteger row = [indexPath row];
	
	EncounterCell *cell = (EncounterCell *)[tableView dequeueReusableCellWithIdentifier:peerTableIdentifier];
	if (cell == nil) {
		cell = [[[EncounterCell alloc] 
				 initWithStyle:UITableViewCellStyleDefault 
				 reuseIdentifier:peerTableIdentifier] autorelease];
		//regular height
		cell.frame = CGRectMake(0.0, 0.0, 320.0, 57.0);
	}
	
	UIImage *image = [UIImage imageNamed:@"unknown-person.png"];

	NSArray *chunks = [[foundPeers objectAtIndex:row] componentsSeparatedByString: @":"];
	uint64_t user_Id = [[chunks objectAtIndex:1] intValue]; //second parameter is user ID
	NSString *tagline = nil;
    if ([chunks count] > 2)
        tagline = [chunks objectAtIndex:2]; //third is tag line
    
	[cell setPeerName:[chunks objectAtIndex:0]
               peerId:user_Id
			 greeting:(tagline==nil)?@"Hello!":tagline
			  peerPic:image
				  row:row];
	
    if (row==0)
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
	return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSString *rowValue = [foundPeers objectAtIndex:row];
	
    if (row == 0) {
        //deselect
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        //circle picker
        if (picker == nil) {
            
            picker = [[CirklePickerSheet alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height) 
                      owner:self 
                      action:@selector(cirklePickerDidFinish:obj:)];
            
            [self.view addSubview:picker];
        }
        
        //set the circle list
        UINavigationController* nav = [[kaya_meetAppDelegate getAppDelegate].tabBarController.viewControllers objectAtIndex:TAB_CIRCLES];
        CirkleViewController *cvc = [nav.viewControllers objectAtIndex:0];
        
        picker.selections = cvc.listCircles;
        [picker.tableView reloadData];
        
        //disable the navbar items
        confirmButton.enabled = NO;
        refreshButton.enabled = NO;
        
        [picker presentView];
        
        return;
    }
    
	NSString *message = [[NSString alloc] initWithFormat:@"You selected %@", rowValue];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Row Selected!" 
													message:message 
												   delegate:nil 
										  cancelButtonTitle:@"Yes I did" 
										  otherButtonTitles:nil];
	[alert show];
	[message release];
	[alert release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (57);
}

#pragma mark -
#pragma mark SessionManager Delegate Methods

- (void)sessionManagerDidFinish:(NSMutableArray *)peersArray {
	//copy the array if we wish to use at all
	NSLog(@"sessionManagerDidFinish: total number of peers found %d\n", [peersArray count]);
}

- (void)sessionManagerDidUpdate:(NSString *)peerName {
	NSLog(@"sessionManagerDidUpdate: new peer %@\n", peerName);
	//add new peer only if it does not already know
	if (![foundPeers containsObject:peerName]) {
		[foundPeers addObject:peerName];
		//add new peer
		NSInteger row = [self.foundPeers count] - 1;
		NSArray* indexPathsInsert = [NSArray arrayWithObjects:
									 [NSIndexPath indexPathForRow:row inSection:0], nil];
			
		[self.peerTableView insertRowsAtIndexPaths:indexPathsInsert 
								  withRowAnimation:UITableViewRowAnimationRight];
	}
}

- (void)cirklePickerDidFinish:(id)sender obj:(NSObject *)obj {
    NSLog(@"cirklePickerDidFinish");
    
    if(obj==nil) {
        NSLog(@"nothing is picked. do nothing");
        
        return;
    }
    
    //confirmButton.enabled = YES;
    //refreshButton.enabled = YES;
    
    CirkleSummary *circle = (CirkleSummary*)obj;
    NSLog(@"You selected circle: %@", circle.nameString);
    
    //refresh and replace 0th cell
    
    //update view
	NSMutableArray* indexPathsDelete = [NSMutableArray array];
	NSInteger rows = [self.foundPeers count];
	
	[self.peerTableView beginUpdates];
	
	for (int i=0; i<rows; i++) {
		[indexPathsDelete addObject: [NSIndexPath indexPathForRow:i inSection:0]];
	}	
	[foundPeers removeAllObjects];
	[self.peerTableView deleteRowsAtIndexPaths:indexPathsDelete  
							  withRowAnimation:UITableViewRowAnimationLeft];
	
	User *user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
	
    NSString *identity;
    
    if(circle.type != CIRCLE_TYPE_SOLO) {
        identity = [NSString stringWithFormat:@"%@:%d:%@:%d",user.name,user.userId,circle.nameString,circle.cId];
        //[foundPeers addObject:[NSString stringWithFormat:@"%@:%d:%@:%d",user.name,user.userId,circle.nameString,circle.cId]];
	} else {
        identity = [NSString stringWithFormat:@"%@:%d:Hello!",user.name,user.userId];
        //to-do: add customizable tag line
        //[foundPeers addObject:[NSString stringWithFormat:@"%@:%d:Hello!",user.name,user.userId]];
    }
    NSLog(@"display name %@",identity);
    
    [foundPeers addObject:identity];
    
	NSArray* indexPathsInsert = [NSArray arrayWithObjects:
								 [NSIndexPath indexPathForRow:0 inSection:0], nil];
	
	[self.peerTableView insertRowsAtIndexPaths:indexPathsInsert 
							  withRowAnimation:UITableViewRowAnimationRight];
	[self.peerTableView endUpdates];

    // let's stop current session if there is one
    
	if (sessionManager) {
		[sessionManager stopSession];
		self.sessionManager = nil;
        [spinner stopAnimating];
        [startStopButton setTitle:@"Start" forState:UIControlStateNormal];
	}
    
    // start a new session based on the new identity
    
	sessionManager = [[SessionManager alloc] initWithDelegate:self];
	
	if (circle.type != CIRCLE_TYPE_SOLO) {
        sessionManager.sessionMode = GKSessionModeServer;
    } else { //peer mode
        sessionManager.sessionMode = GKSessionModePeer;
	}
    
    sessionManager.displayName = identity;
    
    // title label
    NSString *string = [NSString stringWithFormat:@"Adding to Circle: %@", circle.nameString];
    [titleLabel setText:string];

}

@end
