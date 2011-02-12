//
//  MeetViewController.m
//
//  Created by Jun Li on 11/8/10.
//

#import "MeetViewController.h"
#import "kaya_meetAppDelegate.h"
#import "AccelerometerFilter.h"


#define kUpdateFrequency	60.0


@interface MeetViewController (Private)
- (void)didLeaveTab:(UINavigationController*)navigationController;
@end

@implementation MeetViewController

@synthesize soundFileURLRef, soundFileObject; 
//
// UIViewController methods
//
- (void)viewDidLoad
{
	tab       = [self navigationController].tabBarItem.tag;

	// accelerometer
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / kUpdateFrequency];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	filter = [[HighpassFilter alloc] initWithSampleRate:kUpdateFrequency cutoffFrequency:5.0] ;
	filter.adaptive = NO ;
	
	// BT
	bt = [[BluetoothConnect alloc] initWithDelegate:self];
	
	// sound
	// Create the URL for the source audio file. The URLForResource:withExtension: method is
    //    new in iOS 4.0.
    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"tap"
                                                withExtension: @"aif"];
	
    // Store the URL as a CFURLRef instance
    self.soundFileURLRef = (CFURLRef) [tapSound retain];
	
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (
									  soundFileURLRef,
									  &soundFileObject
									  );
}

- (void) viewDidUnload
{
	filter = nil ;
	isLoaded = false;
}

- (void) dealloc
{
	[filter release];
	AudioServicesDisposeSystemSoundID (soundFileObject);
    CFRelease (soundFileURLRef);
	[bt release] ;
	[super dealloc] ;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	if (!isLoaded) {
		// get all meets from server
        [meetDataSource getUserMeets] ;
		
    }else {
		[self.tableView setContentOffset:contentOffset animated:false];
		[self.tableView reloadData];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	isLoaded = true;
}

- (void)viewWillDisappear:(BOOL)animated
{
    contentOffset = self.tableView.contentOffset;
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];

	[meetDataSource cancelConnect];
	//self.navigationItem.leftBarButtonItem.enabled = true;
	self.navigationItem.rightBarButtonItem.enabled = true;
}

- (void)viewDidDisappear:(BOOL)animated 
{	
}

- (void)didReceiveMemoryWarning 
{
//	[self resetMeets];
	[super didReceiveMemoryWarning];
}

// accelerometer
//
// UIAccelerometerDelegate method, called when the device accelerates.
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	static int count = 0 ;
	// Update the accelerometer graph view	
	[filter addAcceleration:acceleration];
	float total = filter.x+filter.y+filter.z ;
	if (total < 2.0 ) return ;
	count ++ ;
	if (count > 2) {
		//NSLog(@"%f, %f, %f" ,filter.x,filter.y,filter.z);
		count = 0 ;
		[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
		[self postMeet:self];
	}
}
// cleanup current meets
// due to different user login

- (void) resetMeets
{
	[meetDataSource removeAllMeets];
//  [self.tableView reloadData];
	isLoaded = false ;
//	contentOffset = 0;
}

//
// called by appDelegate for initialization
//
- (void) restoreAndLoadMeets:(BOOL)load
{
	tab       = [self navigationController].tabBarItem.tag;
	HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.labelText = @"load meets..";
	if (meetDataSource) [meetDataSource release];
	meetDataSource = [[MeetViewDataSource alloc] initWithController:self] ;
	self.tableView.delegate   = meetDataSource;
	self.tableView.dataSource = meetDataSource;
	if ( load ) {
		[meetDataSource getUserMeets];
		isLoaded = true; 
	}
	typeSelector.selectedSegmentIndex = 0 ;
}

- (IBAction) refreshMeet:(id) sender 
{
	self.navigationItem.leftBarButtonItem.enabled = false;
	[meetDataSource getUserMeets];
}

- (IBAction) postMeet:   (id)sender
{
	self.navigationItem.rightBarButtonItem.enabled = false;
	AudioServicesPlaySystemSound (soundFileObject);
	// BT device connection
	[bt   reset ] ;
	HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.labelText = @"finding friend..";
	HUD.detailsLabelText = [NSString stringWithFormat:@".. %d", [bt numberOfPeers]] ;
	[bt startPeer];
}


// post for different modes

- (void) cancelSolo
{
	self.navigationItem.rightBarButtonItem.enabled = true;
	return;
}

- (void) acceptSolo
{
	NSMutableDictionary *param = [NSMutableDictionary dictionary];
	[param setObject:[bt getDisplayName] forKey:@"user_dev"];
	[param setObject:[bt getDisplayName] forKey:@"devs"];
	[meetDataSource addMeet:param];
}

- (void) acceptHost {
	NSMutableDictionary *param = [NSMutableDictionary dictionary];
	[param setObject:[bt getDisplayName] forKey:@"user_dev"];
	[param setObject:[NSString stringWithFormat:@"%@:%@",[bt.devNames objectAtIndex:0],[bt.devNames objectAtIndex:1]] forKey:@"devs"];
	[param setObject:[NSString stringWithFormat:@"%@",[bt.devNames componentsJoinedByString:@":"]] forKey:@"host_id"];
	[param setObject:@"2" forKey:@"host_mode"];
	[meetDataSource addMeet:param];
}

// alterview button 

static UIAlertView *sAlert = nil ;
static SEL  clickedAccept  ;
static SEL  clickedCancel  ;

- (void) cancelHost {
	NSString *meet = [bt findMeet];
	sAlert = nil ;
	if ( meet != nil )
	{ // add to a meet
		[bt getDisplayNames:meet];
		[self dialog:[NSString stringWithFormat:@"Join %@'s meet",[bt.devNames objectAtIndex:0]]  
					message:[NSString stringWithFormat:@"please confirm"] 
					 accept:@selector(acceptJoin)
					 cancel:@selector(collisionJoin)
						 ] ;
		return ;
	}
	NSString *names = [bt getPeerNameList] ;
	if ( names != nil && names != @"") {
		[self dialog:[NSString stringWithFormat:@"meet with %@", names]  
					message:[NSString stringWithFormat:@"please confirm"] 
					 accept:@selector(acceptPeer)
					 cancel:@selector(collisionPeer)
						 ] ;
	}
}

	 
- (void) postJoin:(BOOL)collision
{
	NSMutableDictionary *param = [NSMutableDictionary dictionary];
	[param setObject:[bt getDisplayName] forKey:@"user_dev"];
	[param setObject:[NSString stringWithFormat:@"%@:%@",[bt.devNames objectAtIndex:0],[bt.devNames objectAtIndex:1]] forKey:@"devs"];
	[param setObject:[NSString stringWithFormat:@"%@",[bt.devNames componentsJoinedByString:@":"]] forKey:@"host_id"];
	
	[param setObject:@"4" forKey:@"host_mode"];
	if( collision == true ) {
		[param setObject:@"1" forKey:@"collision"];
	} else {
		[param setObject:@"0" forKey:@"collision"];
	}
	
	[meetDataSource addMeet:param];
}

- (void) acceptJoin
{
	[self postJoin:false];
}

- (void) collisionJoin
{
	[self postJoin:true];
}

- (void) postPeer:(BOOL)collision
{
	NSMutableDictionary *param = [NSMutableDictionary dictionary];
	NSString* query = [bt.peerList componentsJoinedByString:@","];
	[param setObject:query forKey:@"devs"];
	[param setObject:[bt getDisplayName] forKey:@"user_dev"];
	if( collision == true ) {
		[param setObject:@"1" forKey:@"collision"];
	} else {
		[param setObject:@"0" forKey:@"collision"];
	}
	[meetDataSource addMeet:param];
}

- (void) collisionPeer
{
	[self postPeer:true];
}

- (void) acceptPeer 
{
	[self postPeer:false];
}

// hostmode, addmode, peermode

- (void) BluetoothDidFinished:(BluetoothConnect *)Bluetooth {

	[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];	
	self.navigationItem.rightBarButtonItem.enabled = true;
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	if( [bt numberOfPeers] == 0 && bt.mode != BT_ADD ) { // solo
		[self dialog:@"Solo Meet"  
					message:[NSString stringWithFormat:@"please confirm"] 
					 accept:@selector(acceptSolo) 
					 cancel:@selector(cancelSolo)] ;
		return ;
	}
	
	NSString *host = [Bluetooth findHost];
	
	if ( host != nil )
	{ // host
		[bt getDisplayNames:host];
		[self dialog:[NSString stringWithFormat:@"Join %@'s %@",[bt.devNames objectAtIndex:0],[bt.devNames objectAtIndex:2]]  
					message:[NSString stringWithFormat:@"please confirm"] 
					 accept:@selector(acceptHost)
					 cancel:@selector(cancelHost)
						] ; 
		return ;
	}
	
	NSString *meet = [Bluetooth findMeet];
	if ( meet != nil )
	{ // add to a meet
		[bt getDisplayNames:meet];
		[self dialog:[NSString stringWithFormat:@"Join %@'s meet",[bt.devNames objectAtIndex:0]]
					message:[NSString stringWithFormat:@"please confirm"] 
					 accept:@selector(acceptJoin)
					 cancel:@selector(collisionJoin)
						] ;
		return ;
	}
	NSString *names = [bt getPeerNameList] ;
	if ( names != nil && names != @"") {
		[self dialog:[NSString stringWithFormat:@"meet with %@", names]  
				message:[NSString stringWithFormat:@"please confirm"] 
				 accept:@selector(acceptPeer)
				 cancel:@selector(collisionPeer )
					 ] ;
	}
	
}

- (void) BluetoothDidUpdate:(BluetoothConnect *)Bluetooth peer:(NSString *)peerID{
	HUD.detailsLabelText = [NSString stringWithFormat:@".. %d", [Bluetooth numberOfPeers]] ;
}

- (void) autoRefresh
{
    //[self refreshMeet:nil];
}

- (void)postViewAnimationDidFinish
{
    if (self.navigationController.topViewController != self) return;
    
    if (tab == TAB_MEETS) {
        //
        // Do animation if the controller displays meets.
        //
        NSArray *indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
	
}

//
// kaya_meetAppDelegate delegate
//
- (void)didLeaveTab:(UINavigationController*)navigationController
{
    //for (int i = 0; i < [meetDataSource countMeets]; ++i) {
     //   KYMeet* sts = [meetDataSource meetAtIndex:i];
    //}
}

- (void) removeMeet:(KYMeet*)meet
{
    [meetDataSource removeMeet:meet];
    [self.tableView reloadData];
}

// MeetViewControllerDelegate 
- (void) meetsDidUpdate:(MeetViewDataSource*)sender count:(int)count insertAt:(int)position
{
	//self.navigationItem.leftBarButtonItem.enabled = true;
	self.navigationItem.rightBarButtonItem.enabled = true;
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (self.navigationController.tabBarController.selectedIndex == tab &&
        self.navigationController.topViewController == self) {
		
        [self.tableView beginUpdates];
        if (position) {
            NSMutableArray *deletion = [[[NSMutableArray alloc] init] autorelease];
            [deletion addObject:[NSIndexPath indexPathForRow:position inSection:0]];
            [self.tableView deleteRowsAtIndexPaths:deletion withRowAnimation:UITableViewRowAnimationFade];
        }
		int numInsert = count;
        if (count != 0) {
            NSMutableArray *insertion = [[[NSMutableArray alloc] init] autorelease];
            // Avoid to create too many table cell.
            //if (numInsert > 8) numInsert = 8;
            for (int i = 0; i < numInsert; ++i) {
                [insertion addObject:[NSIndexPath indexPathForRow:position + i inSection:0]];
            }
            [self.tableView insertRowsAtIndexPaths:insertion withRowAnimation:UITableViewRowAnimationRight];
        }
        [self.tableView endUpdates];
    }
}

- (void) meetsDidFailToUpdate:(MeetViewDataSource *)sender position:(int)position
{
	//self.navigationItem.leftBarButtonItem.enabled = true;
	self.navigationItem.rightBarButtonItem.enabled = true;
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

// message return screen

- (void)messageViewAnimationDidFinish
{
    if (self.navigationController.topViewController != self) return;
	
    if (tab == TAB_MEETS) {
        //
        // Do animation if the controller displays
        //
        NSArray *indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
	
}

- (NSArray*) getMeets 
{
	return meetDataSource.meets ;
}

- (MeetViewDataSource *)meetDataSource 
{
	return meetDataSource ;
}

// segmentedControl
- (void) typeSelected:(id)sender
{
	if (self.navigationController.topViewController != self)    return;
	if (tab == TAB_MEETS) {
		UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	
		meetDataSource.showType=[segmentedControl selectedSegmentIndex];

		[self.tableView reloadData];
	}
}




- (void)dialog:(NSString*)title message:(NSString*)message accept:(SEL)aAction cancel:(SEL)cAction
{
	if (sAlert) return;
	sAlert = [[UIAlertView alloc] initWithTitle:title
										message:message
									   delegate:self
							  cancelButtonTitle:@"Accept"
							  otherButtonTitles:@"Cancel", nil];
	clickedAccept  = aAction ;
	clickedCancel  = cAction ;
	[sAlert show];
	[sAlert release];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"click %d",buttonIndex);
	if ( buttonIndex == 0 && [self respondsToSelector:clickedAccept] )
	{
		[self performSelector:clickedAccept] ;
	}
	else if ( buttonIndex == 1 && [self respondsToSelector:clickedCancel] ){
		[self performSelector:clickedCancel] ;
	}
	sAlert = nil ; 
}

@end
