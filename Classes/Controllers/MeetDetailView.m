//
//  MeetDetailView.m
//  kaya_meet
//
//  Created by Jun Li on 12/25/10.
//
#import <QuartzCore/QuartzCore.h>
#import "MeetDetailView.h"
#import "FriendViewCell.h"
#import "meetDisplayMap.h"
#import "UACellBackgroundView.h"
#import "kaya_meetAppDelegate.h"

@implementation MeetDetailView

@synthesize currentMeet;

@synthesize friendsView, mapView, messageView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithMeet:(KYMeet *)meet {
    if (self) {
        // Custom initialization.
		currentMeet = meet ;
		loadCell  = [[LoadCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"FriendLoadCell"];
		[loadCell setType:1];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// set title
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	}
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:currentMeet.timeAt];        
	self.navigationItem.title = [NSString stringWithFormat:@"@ %@", [dateFormatter stringFromDate:date]];
	
	if(  currentMeet.userCount == 1 ) {
		friendsView.hidden = true ;
		mapView = [[UIImageView alloc] initWithFrame:CGRectMake(16,25,288,90)] ;
		//mapView.frame = CGRectMake(16,25,288,90) ;
	} else {
		mapView = [[UIImageView alloc] initWithFrame:CGRectMake(16,25,110,90)];
		//mapView.frame = CGRectMake(16,25,110,90) ;
		friendsView.frame = CGRectMake(128,25, 175,90);
	}
	[self.view addSubview:mapView];
	CALayer *ly = [mapView layer];
	[ly setMasksToBounds:YES];
	[ly setCornerRadius:5.0];
	[mapView release];
	
	// textView
	messageView.layer.cornerRadius = 5.0;
	messageView.font = [UIFont systemFontOfSize:13];
	messageView.text = @"";
	// actionButtons
	
	// set friendsView 
	[friendsView setDelegate:self];
	[friendsView setDataSource:self];
	friendsView.layer.cornerRadius = 5.0;
	friendsView.backgroundColor = [UIColor clearColor];
	friendsView.separatorColor = [UIColor clearColor];
	[friendsView setAlwaysBounceVertical:YES];
	
	[self getMeetDetails];
}


- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (meetDetailClient != nil ) {
		[meetDetailClient cancel];
		[meetDetailClient release];
		meetDetailClient = nil;
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
}


- (void)dealloc {
    [loadCell release] ;
    if ( [ currentMeet.meetUsers count ] )
    {
	 [currentMeet.meetUsers removeAllObjects];
    }
    [super dealloc];
}

// load meet details

- (void)getMeetDetails
{
    if (meetDetailClient) return;
	meetDetailClient = [[KYMeetClient alloc] initWithTarget:self action:@selector(detailsDidReceive:obj:)];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
	// get meets from server
    [meetDetailClient getMeet:param withMeetId:currentMeet.meetId];
}

- (void)detailsDidReceive:(KYMeetClient*)sender obj:(NSObject*)obj
{
	meetDetailClient = nil;    
	[loadCell.spinner stopAnimating];
    if (sender.hasError) {
        if (sender.statusCode == 401) { // authentication fail
            kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate openLoginView];
        }
        [sender alert];
    }
	
    if (obj == nil || ! [obj isKindOfClass:[NSDictionary class]] )  {
		// didn't get any meet from server
        return;
    }
	NSDictionary *dic = (NSDictionary*)obj ;
	dic = [dic objectForKey:@"meet"] ;
	if (![dic isKindOfClass:[NSDictionary class]]) {
		return;
	}
	[currentMeet updateWithJsonDictionary:dic] ;
	[self updateFriendList];
 
}

- (void) updateFriendList
{
	int numInsert = [currentMeet.meetUsers count];
	if (numInsert != 0) {
		[self.friendsView beginUpdates];
		NSMutableArray *insertion = [[[NSMutableArray alloc] init] autorelease];
		for (int i = 0; i < numInsert; ++i) {
			[insertion addObject:[NSIndexPath indexPathForRow:i inSection:0]];
		}
		[self.friendsView insertRowsAtIndexPaths:insertion withRowAnimation:UITableViewRowAnimationNone];
		[self.friendsView endUpdates];
	}
	
	if (currentMeet.latestChat == nil) 
		self.messageView.text = [NSString stringWithFormat:@"@ %@",currentMeet.place] ;
	else {
		self.messageView.text = [NSString stringWithFormat:@"%@",currentMeet.latestChat] ;
	}
	// set MayImageView
	NSString *headmapurl0 = @"http://maps.google.com/maps/api/staticmap?zoom=11&size=110x90&maptype=roadmap&format=png32&markers=color:green|size:small";
	NSString *headmapurl1 = @"http://maps.google.com/maps/api/staticmap?zoom=11&size=290x90&maptype=roadmap&format=png32&markers=color:green|size:small";
	NSString *mapurl = [NSString stringWithFormat:@"%@|%lf,%lf&sensor=false",currentMeet.userCount > 1 ?headmapurl0:headmapurl1,currentMeet.latitude,currentMeet.longitude];
	mapurl = [mapurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:mapurl] ;
	NSData *mapdata = [[NSData alloc] initWithContentsOfURL:url];
	UIImage *uimap = [[UIImage alloc] initWithData:mapdata];
	mapView.image = uimap; 
	[mapdata release];
	[uimap release];
//	[url release];

}

// Friend view list

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection: (NSInteger)section
{
    //return @"People you met with";
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return nil;
}

- (User *) userAtIndex:(int)index 
{
	return [currentMeet.meetUsers objectAtIndex:index] ;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (currentMeet.meetUsers == nil) return 0 ;
    else return [currentMeet.meetUsers count]  ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return  currentMeet.userCount > 1 ? 45 : 90;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
	if ( [currentMeet.meetUsers count] < 2 ) return ;
	if ( indexPath.row == 0 ) {
		[(UACellBackgroundView *)cell.backgroundView setPosition:UACellBackgroundViewPositionTop];
	} else if ( indexPath.row == [currentMeet.meetUsers count]-1 ){
		[(UACellBackgroundView *)cell.backgroundView setPosition:UACellBackgroundViewPositionBottom];
	} else {
		[(UACellBackgroundView *)cell.backgroundView setPosition:UACellBackgroundViewPositionMiddle];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	User* u = [self userAtIndex:indexPath.row];
    if (u == nil) return loadCell;
    
    FriendViewCell* cell = (FriendViewCell*)[friendsView dequeueReusableCellWithIdentifier:@"FriendCell"];
    if (!cell) {
        cell = [[[FriendViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendCell" ] autorelease];
    }
	
	cell.nameLabel.text   = u.name  ;
	
	NSString *picURL = u.profileImageUrl ;
	if ((picURL != (NSString *) [NSNull null]) && (picURL.length !=0)) {
		NSURL  *url = [NSURL URLWithString:picURL] ;
		NSData *imgData = [NSData dataWithContentsOfURL:url];
		UIImage *aImage = [[UIImage alloc] initWithData:imgData];
		CGSize itemSize  = CGSizeMake(40,40);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0,0.0,itemSize.width, itemSize.height);
		[aImage drawInRect:imageRect];
		cell.friendImageView.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[aImage release];
	} else {
		cell.friendImageView.image = nil;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];   
}

/* mapView 

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
	MKPinAnnotationView *pinView = nil; 
	if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	if([annotation isKindOfClass:[meetDisplayMap class]])
	{
		static NSString *defaultPinID = @"com.kayameet.detailPin";
		pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
		if ( pinView == nil ) pinView = [[[MKPinAnnotationView alloc]
										  initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
		pinView.pinColor = MKPinAnnotationColorPurple; 
		pinView.canShowCallout = NO;
		pinView.animatesDrop = NO;
		pinView.annotation = annotation ;
	} 
//	else {
//		[mapView.userLocation setTitle:@"you are here"];
//	}
	return pinView;
}
 */

// IBActions 

- (IBAction) postMessage:(id) sender 
{
	kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
	MessageViewController *mV = appDelegate.messageView ;
	
	[mV postTo:currentMeet];
}

- (IBAction) inviteFriend:(id) sender 
{
	kaya_meetAppDelegate *appDelegate = (kaya_meetAppDelegate*)[UIApplication sharedApplication].delegate;
	MessageViewController *mV = appDelegate.messageView ;
	
	[mV inviteTo:currentMeet];
}

@end
