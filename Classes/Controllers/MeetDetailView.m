//
//  MeetDetailView.m
//  kaya_meet
//
//  Created by Jun Li on 12/25/10.
//  Copyright 2010 Anova Solutions Inc. All rights reserved.
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
	// set mapView
	[mapView setMapType:MKMapTypeStandard];
	[mapView setZoomEnabled:YES];
	[mapView setScrollEnabled:YES];
	MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } }; 
	region.center.latitude = currentMeet.latitude ;
	region.center.longitude = currentMeet.longitude;
	region.span.longitudeDelta = 0.05f;
	region.span.latitudeDelta = 0.05f;
	[mapView setRegion:region animated:YES]; 
	[mapView setDelegate:self];
	
	meetDisplayMap *ann = [[meetDisplayMap alloc] init]; 
	ann.coordinate = region.center; 
	[mapView addAnnotation:ann];
	mapView.layer.cornerRadius = 5.0;
	[ann release];
	
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
	[friendsView setAlwaysBounceVertical:YES];
	
	[self getMeetDetails];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
	if ( currentMeet.meetUsers != nil )
	{
		currentMeet.meetUsers = nil ;
	}
	if (currentMeet.place != nil){
		currentMeet.place = nil ;
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
	[self.friendsView beginUpdates];
	int numInsert = [currentMeet.meetUsers count];
	if (numInsert != 0) {
		NSMutableArray *insertion = [[[NSMutableArray alloc] init] autorelease];
		for (int i = 0; i < numInsert; ++i) {
			[insertion addObject:[NSIndexPath indexPathForRow:i inSection:0]];
		}
		[self.friendsView insertRowsAtIndexPaths:insertion withRowAnimation:UITableViewRowAnimationNone];
	}
	[self.friendsView endUpdates];
	
	if (currentMeet.latestChat == nil) 
		self.messageView.text = [NSString stringWithFormat:@"@ %@",currentMeet.place] ;
	else {
		self.messageView.text = [NSString stringWithFormat:@"%@",currentMeet.latestChat] ;
	}

}

// Friend view list

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection: (NSInteger)section
{
    return @"People you met with";
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
	return  55 ;
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
        cell = [[[FriendViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendCell"] autorelease];
    }
	
	cell.nameLabel.text   = u.name  ;
	
	NSString *picURL = u.profileImageUrl ;
	if ((picURL != (NSString *) [NSNull null]) && (picURL.length !=0)) {
		NSData *imgData = [[[NSData dataWithContentsOfURL:
							 [NSURL URLWithString:picURL]] autorelease] retain];
		UIImage *aImage = [[UIImage alloc] initWithData:imgData];
		CGSize itemSize  = CGSizeMake(50,50);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0,0.0,itemSize.width, itemSize.height);
		[aImage drawInRect:imageRect];
		cell.friendImageView.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	} else {
		cell.friendImageView.image = nil;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];   
}

// mapView 

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

@end
