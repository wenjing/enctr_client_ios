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

@implementation EncounterViewController
@synthesize sessionManager;
@synthesize foundPeers;
@synthesize refreshButton;
@synthesize confirmButton;
@synthesize peerTableView;
@synthesize spinner;
@synthesize postRequests;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Other initialization moved to tab selected	
    postRequests = [[NSMutableArray alloc] init];
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
}


- (void)dealloc {
	[foundPeers removeAllObjects];
	[foundPeers release];
	[sessionManager stopSession];
	[sessionManager release];
	
	[refreshButton release];
	[confirmButton release];
	[spinner release];
    
    //dealloc calls cancel
    [postRequests removeAllObjects];
    [postRequests release];
    
    [super dealloc];
}

-(IBAction) refreshButtonPressed {
	/*
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Refresh button selected!" 
													message:@"Correct?"
												   delegate:nil 
										  cancelButtonTitle:@"Yes I did" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	*/
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
	
	[foundPeers addObject:[NSString stringWithFormat:@"%@:%d",user.name,user.userId]];
	
	NSArray* indexPathsInsert = [NSArray arrayWithObjects:
								 [NSIndexPath indexPathForRow:0 inSection:0], nil];
	
	[self.peerTableView insertRowsAtIndexPaths:indexPathsInsert 
							  withRowAnimation:UITableViewRowAnimationRight];
	[self.peerTableView endUpdates];
	
	//[self.peerTableView reloadData];
	
	//start a new session
	sessionManager = [[SessionManager alloc] initWithDelegate:self];
	
	//to-do: change mode as our identity changes
	currentMode = GKSessionModePeer;
	
	[sessionManager startSession:GKSessionModePeer];
	
	confirmButton.enabled = YES;
	[spinner startAnimating];
}

-(IBAction) confirmButtonPressed {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New encounter" 
													message:@"in your circles"
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
	
	foundPeers = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%@:%d",user.name,user.userId], nil];
	
	sessionManager = [[SessionManager alloc] initWithDelegate:self];
	
	//to-do: change mode as our identity changes
	currentMode = GKSessionModePeer;
	//Client may be working, don't set it to nil here
	
	[sessionManager startSession:GKSessionModePeer];
	confirmButton.enabled = YES;
	[self.peerTableView reloadData];
	[spinner startAnimating];
	
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

    /*
    while ((client = [enumerator nextObject])) {
        if (client.toBeRetried) {
            //Add this to retryList
            [retryList addObject:<#(id)#>
            NSLog(@"retryPostToServer found an encounter post to retry");
            
            //to avoid depdency on client behavior, create a new client
            KYMeetClient *postClient = [[KYMeetClient alloc] initWithTarget:self action:@selector(encounterDidPost:obj:)];
            
            // retain the postMessage dictionary
            postClient.postParams = client.postParams;
            
            // retain the Client
            [postClient retain];
            [postRequests addObject:postClient];
            
            // post meet to server
            [postClient postMeet:postClient.postParams];
            
            //
            //release the old client
            [client release];
            
            count++;
        }
    }
    */
    
    NSLog(@"retryPostToServer done with %d posts retried", count);
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.foundPeers count];
}

/* not allow selecting the first row */
 - (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	 NSUInteger row = [indexPath row];
	 if (row == 0) {
		 return nil;
	 }
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
	NSInteger userId = [[chunks objectAtIndex:1] intValue];
/*	
	User *user = [User userWithId:userId];
	if (user) {
		//to-do: Use HJCache to get image via user.profileImageUrl
		switch (userId % 5) {
			case 0:
				image = [UIImage imageNamed:@"person3.png"];
				break;
			case 1:
				image = [UIImage imageNamed:@"person2.png"];
				break;
			case 2:
				image = [UIImage imageNamed:@"person1.png"];
				break;
			case 3:
				image = [UIImage imageNamed:@"person4.png"];
				break;
			case 4:
				image = [UIImage imageNamed:@"person5.png"];
				break;
			default:
				break;
		}
	}
 */
	
	[cell setPeerName:[chunks objectAtIndex:0]
               peerId:userId
			 greeting:@"Hi, glad to meet you!"
			  peerPic:image
				  row:row];
	
	return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSString *rowValue = [foundPeers objectAtIndex:row];
	
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


@end
