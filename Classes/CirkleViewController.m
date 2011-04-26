//
//  CirkleViewController.m
//  Cirkle
//
//  Created by Wenjing Chu on 3/27/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirkleViewController.h"
#import "CirkleEntryCell.h"
#import "CirkleQuery.h"
#import "CirkleSummary.h"
#import "CirkleEntryView.h"
#import "CirkleDetailViewController.h"
#import "kaya_meetAppDelegate.h"
#import "EncounterViewController.h"
#import "CirklePrompt.h"
#import "StringUtil.h"

@implementation CirkleViewController
@synthesize listCircles;
@synthesize query;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    if (listCircles)
        [listCircles removeAllObjects];
    [listCircles release];
    if (query) {
        [query clear];
    }
    [query release];
    _refreshHeaderView=nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// called by logout to clear 
// to-do: do i need to consider that a circleDetail view may be on??
- (void)clear {
    if (listCircles)
        [listCircles removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

-(void)restoreAndLoadCirkles:(BOOL)withUpdate
{
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    _reloading = YES;
    
    if (!withUpdate) {
        CirkleQuery *firstQuery = [[CirkleQuery alloc] initWithTarget:self 
                                                               action:@selector(cirklesDidLoad:)
                                                    releaseAtCallBack:true];
        [firstQuery query:options withUpdate:withUpdate];
    } else {
        if (query)
            [query clear];
    
        [query query:options withUpdate:withUpdate];
    }
    
}

- (void)cirklesDidLoad:(CirkleQuery*)sender
{
    
    //NSLog(@"Load cirkle results");
    if ([sender hasError]) {
        
        NSLog(@"Network agent error while updating circle view");
        
    } else {
        
        if ([sender hasMore]) {
            NSLog(@"  has more");
        }
        
        NSArray *results = [sender getResults];
    
        //NSLog(@"Loaded circles: %@", results);
        
        //if the result is not empty, then rebuild listCircles

        NSInteger count = [results count];
        
        if (count > 0) {
            [listCircles removeAllObjects];
        
            NSLog(@"start rebuilding %d circles\n", count);
        
            for (int i=0; i<count; i++) {

                NSDictionary *dic = [results objectAtIndex:i];
        
                CirkleSummary *circle = [[CirkleSummary alloc] initWithJsonDictionary:dic];
        
                [listCircles addObject:circle];
                //NSLog(@"adding %d-th circle to list\n", i);
            }
        
            //NSLog(@"%@", listCircles);
            [self.tableView reloadData];
        }
        
        if (sender != query) {
            //must set to true
            [self restoreAndLoadCirkles:true];
        }

    }

    //[sender clear];
    
    _reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
/*   
    if (sender != query) {
        //must set to true
        [self restoreAndLoadCirkles:true];
    }
*/ 
}


- (void)invitationDidConfirm:(KYMeetClient*)sender obj:(NSObject*)obj
{
    NSLog(@"Confirm invitation results");
    if ([sender hasError]) {
        NSLog(@"  has error");
    } else {
        //NSLog(@"%@", obj);
    }
}

- (IBAction) addCircleAction:(id)sender
{
    //prompt for circle name
    CirklePrompt *prompt = [[CirklePrompt alloc] initWithTitle:@"Enter Circle Name" message:@"                       " delegate:self cancelButtonTitle:@"Cancel" okButtonTitle:@"Done"];
    [prompt show];
    [prompt release];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        NSString *circleName = [(CirklePrompt *)alertView enteredText];
        NSLog(@"creating new circle: %@", circleName);
        // validate
        NSRange range = [circleName rangeOfString:@":"];
        NSRange rangeb = [circleName rangeOfString:@";"];
        if (range.location != NSNotFound || rangeb.location != NSNotFound) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name can't contain colon \":\" or semicolon \";\"" 
                                                            message:@"Please try again"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        // send mpost to server
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        User *user = [User userWithId:[[NSUserDefaults standardUserDefaults] integerForKey:@"KYUserId" ]];
        NSTimeInterval dtime = [NSDate timeIntervalSinceReferenceDate];
        
        NSString *identity = [NSString stringWithFormat:@"%@:%d:%@:%d:%lld",user.name,user.userId,circleName,0,(uint64_t)(dtime)];
        
        [param setObject:identity forKey:@"user_dev"];
        
        // these are unused - keep them for now until server is ready to skip them
        [param setObject:@"3" forKey:@"host_mode"];
        
        [param setObject:@"0" forKey:@"collision"];
        
        [param setObject:@"" forKey:@"devs"];
        
        // meet date
        time_t now;
        time(&now);
        [param setObject:[NSString dateString:now] forKey:@"time"];
        
        // location 
        kaya_meetAppDelegate *del = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
        
        [param setObject:[NSString stringWithFormat:@"%lf",del.latitude]  forKey:@"lat" ];
        [param setObject:[NSString stringWithFormat:@"%lf",del.longitude] forKey:@"lng"];
        [param setObject:[NSString stringWithFormat:@"%f", del.lerror]    forKey:@"lerror"];
        
        KYMeetClient *postClient = [[KYMeetClient alloc] initWithTarget:self action:@selector(newCircleDidPost:obj:)];
        [postClient postMeet:param];
        
    } else {
        // dismiss - and do nothing
    }
}

- (void)newCircleDidPost:(KYMeetClient*)sender obj:(NSObject*)obj
{
    if (sender.hasError) {
        [sender alert];
    } else {
        [self restoreAndLoadCirkles:TRUE];
    }
        
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // reload circles every time view is reloaded
    listCircles = [[NSMutableArray alloc] init];
    
    query = [CirkleQuery alloc];
    [query initWithTarget:self 
                   action:@selector(cirklesDidLoad:)
        releaseAtCallBack:false];
    
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:
                                           CGRectMake(0.0f, 
                                                      0.0f - self.tableView.bounds.size.height, 
                                                      self.view.frame.size.width, 
                                                      self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
    
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    [self restoreAndLoadCirkles:false];
    
    // add button as the nav bar's custom right view
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                   target:self 
                                   action:@selector(addCircleAction:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [listCircles removeAllObjects];
    self.listCircles = nil;
    if (query) {
        [query clear];
    }
    [query release];
    query = nil;
    _refreshHeaderView=nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //NSLog(@"viewWillAppear circleView");
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.listCircles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CircleTableIdentifier = @"CircleTableIdentifier";
    //static NSInteger i=0;
    
	NSUInteger row = [indexPath row];
	//NSLog(@"calling cellForRowAtIndexPath, row %d", row);
    
	CirkleEntryCell	*cell = (CirkleEntryCell *)[tableView dequeueReusableCellWithIdentifier:CircleTableIdentifier];
	if (cell == nil) {
		cell = [[[CirkleEntryCell alloc] 
				 initWithStyle:UITableViewCellStyleDefault 
				 reuseIdentifier:CircleTableIdentifier] autorelease];
        //NSLog(@"A new circle view cell %d allocated, row %d", ++i, row);
    }
    
    [cell setCircle:[listCircles objectAtIndex:row]];
    
    //refactor later
    CGSize sizeOfFrame = [cell getSize];
    
    cell.frame = CGRectMake(0.0, 0.0, 320.0, GENERIC_MARGIN*2+PIC_WIDTH+sizeOfFrame.height+GENERIC_MARGIN*2+LG_PIC_SIZE);

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
    //NSLog(@"calling heightForRowAtIndexPath row %d",row);
    
    CirkleSummary *circle = [listCircles objectAtIndex:row];
    
    if (circle.size.height == 0) {
        CGRect drawRect = CGRectMake(GENERIC_MARGIN*2+PIC_WIDTH, 0.0, CONTENT_WIDTH, 9999.0);
	
        circle.size = [circle.contentString sizeWithFont:[UIFont systemFontOfSize:MAIN_FONT_SIZE] 
                                   constrainedToSize:drawRect.size];
	
        //NSLog(@"Row %d content Text Size = %@", row, NSStringFromCGSize(circle.size));
    }
    
	if ([circle.imageUrl count] > 0) {//if we have photo - 
		return (GENERIC_MARGIN*2+PIC_WIDTH+circle.size.height+GENERIC_MARGIN*2+LG_PIC_SIZE);
	}
    
	return (GENERIC_MARGIN*2+PIC_WIDTH+circle.size.height+GENERIC_MARGIN);
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"click %d",buttonIndex);
    if ( buttonIndex == 0  )
    {
        //confirm
        KYMeetClient *client = [[KYMeetClient alloc] initWithTarget:self action:@selector(invitationDidConfirm:obj:)];
        NSUInteger row = alertView.tag;
        CirkleSummary *aCircle = [listCircles objectAtIndex:row];
        
        BOOL confirm = true;
        [client confirmInvitation:confirm forMeetId:aCircle.cId];
    }
    else if ( buttonIndex == 1 ){
        //cancel - does nothing
    }
}

#pragma mark -
#pragma mark Table Delegate Methods
/*
 - (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
 NSUInteger row = [indexPath row];
 return row;
 }
 */
/* an example of not allow selecting the first row
 - (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 NSUInteger row = [indexPath row];
 if (row == 0) {
 return nil;
 }
 return indexPath;
 }
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
    CirkleSummary *aCircle = [listCircles objectAtIndex:row];
    
    if (aCircle.type == CIRCLE_TYPE_INVITE) {
        NSString *rowValue = aCircle.nameString;
	
        NSString *message = [[NSString alloc] initWithFormat:@"Join the Circle: \"%@\"?", rowValue];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You are invited!" 
													message:message 
												   delegate:self
										  cancelButtonTitle:@"Yes I will" 
										  otherButtonTitles:@"Cancel", nil];
        alert.tag = row;
        [alert show];
        [message release];
        [alert release];
        
        return;
    }
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    CirkleDetailViewController *detailViewController = [[CirkleDetailViewController alloc] initWithNibName:@"CirkleDetailViewController" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    detailViewController.summary = aCircle;
    detailViewController.upperController = self;
    
    detailViewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	//[self reloadTableViewDataSource];
	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    [self restoreAndLoadCirkles:true];
	
    //retry unsuccessful encounter posts
    kaya_meetAppDelegate *del = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
    
    UINavigationController* nav = (UINavigationController*)[del getAppTabController:TAB_ENCOUNTER];
	EncounterViewController* evc = (EncounterViewController*)[nav.viewControllers objectAtIndex:0]  ;
    
    if (evc) {
        //hook #1
        [evc retryPostToServer];
    } else {
        NSLog(@"Internal Error: could not find encounterViewController!");
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


@end
