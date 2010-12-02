//
//  MeetViewController.m
//
//  Created by Jun Li on 11/8/10.
//

#import "MeetViewController.h"
#import "MBProgressHUD.h"
#import "kaya_meetAppDelegate.h"

@interface MeetViewController (Private)
- (void)didLeaveTab:(UINavigationController*)navigationController;
@end

@implementation MeetViewController

//
// UIViewController methods
//
- (void)viewDidLoad
{
    if (!isLoaded) {
		// get all meets from server
        [meetDataSource getUserMeets] ;
    }
	isLoaded = true;
}

- (void) dealloc
{
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    [self.tableView setContentOffset:contentOffset animated:false];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (!isLoaded) {
		// get all meets from server
        [meetDataSource getUserMeets] ;
    }
	isLoaded = true;
}

- (void)viewWillDisappear:(BOOL)animated
{
    contentOffset = self.tableView.contentOffset;
}

- (void)viewDidDisappear:(BOOL)animated 
{
}

- (void)didReceiveMemoryWarning 
{
}

//
// called by appDelegate for initialization
//
- (void) restoreAndLoadMeets:(BOOL)load
{
	tab       = [self navigationController].tabBarItem.tag;
	meetDataSource = [[MeetViewDataSource alloc] initWithController:self] ;
	self.tableView.delegate   = meetDataSource;
	self.tableView.dataSource = meetDataSource;
	if ( load ) {
		[meetDataSource getUserMeets];
		isLoaded = true; 
	}
}

- (IBAction) refreshMeet:(id) sender 
{
	self.navigationItem.leftBarButtonItem.enabled = false;
	[meetDataSource getUserMeets];
}

static MBProgressHUD *HUD = nil ;

- (IBAction) postMeet:   (id)sender
{
	self.navigationItem.rightBarButtonItem.enabled = false;
	// BT device connection
	// BT ids
	static BluetoothConnect *bt ;
	if ( bt == nil ) 
		 bt = [[BluetoothConnect alloc] initWithDelegate:self];
	[bt   reset ] ;
	HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.labelText = @"finding friend..";
	HUD.detailsLabelText = [NSString stringWithFormat:@".. %d", [bt numberOfPeers]] ;
	[bt startPeer];
}

- (void) BluetoothDidFinished:(BluetoothConnect *)bt {
	[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
	[meetDataSource addMeet:bt] ;
}

- (void) BluetoothDidUpdate:(BluetoothConnect *)bt peer:(NSString *)peerID{
	HUD.detailsLabelText = [NSString stringWithFormat:@".. %d", [bt numberOfPeers]] ;
}

- (void) autoRefresh
{
	// get location update if needed
	[meetDataSource getLocation];
	
	[self refreshMeet:nil];
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
    navigationController.tabBarItem.badgeValue = nil;
    for (int i = 0; i < [meetDataSource countMeets]; ++i) {
     //   KYMeet* sts = [meetDataSource meetAtIndex:i];
    }
}

- (void) removeMeet:(KYMeet*)meet
{
    [meetDataSource removeMeet:meet];
    [self.tableView reloadData];
}

// MeetViewControllerDelegate 
- (void) meetsDidUpdate:(MeetViewDataSource*)sender count:(int)count insertAt:(int)position
{
	self.navigationItem.leftBarButtonItem.enabled = true;
	self.navigationItem.rightBarButtonItem.enabled = true;

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
 //           if (numInsert > 8) numInsert = 8;
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
	self.navigationItem.leftBarButtonItem.enabled = true;
}

@end
