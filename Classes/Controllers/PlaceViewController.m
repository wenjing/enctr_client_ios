    //
//  PlaceViewController.m
//  kaya_meet
//
//  Created by Jun Li on 1/1/11.
//
#import <QuartzCore/QuartzCore.h>
#import "PlaceViewController.h"
#import "placeDisplayMap.h"
#import "MeetDetailView.h"
#import "kaya_meetAppDelegate.h"
#import "MeetViewController.h"

@implementation PlaceViewController

@synthesize dbmeets, meetMapView, mapView ;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		if ( meetMapView == nil ) meetMapView = [MKMapView alloc];
		meetMapView.delegate = self;
		meetMapView.frame = [[UIScreen mainScreen] applicationFrame];
	}
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	// dbmeets = [[NSMutableArray alloc] init];
	if ( meetMapView == nil ){
		meetMapView =[[MKMapView alloc] initWithFrame:CGRectMake(0,0,mapView.frame.size.width, mapView.frame.size.height)];
		meetMapView.delegate = self;
		[self.mapView addSubview:meetMapView];
		[meetMapView release];
	}
	showType = MEET_ALL ;
}

- (void)viewWillAppear:(BOOL)animate {
	if ( meetMapView == nil ) {
		meetMapView =[[MKMapView alloc] initWithFrame:CGRectMake(0,0,mapView.frame.size.width, mapView.frame.size.height) ];
		meetMapView.delegate = self;
		[self.mapView addSubview:meetMapView];
		[meetMapView release];
	}
	//meetMapView.showsUserLocation=TRUE;
	kaya_meetAppDelegate *appDelegate = [kaya_meetAppDelegate getAppDelegate];
	MeetViewController *mc = [appDelegate getAppMeetViewController] ;
	dbmeets = [mc getMeets] ;
	[appDelegate addObserver:self forKeyPath:@"latitude" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
/*	[meetMapView.userLocation addObserver:self  
							forKeyPath:@"location"  
							options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
								context:NULL];
 */
	[self refreshMeetMap] ;
}

- (void)viewDidDisappear:(BOOL)animated{
	if ( meetMapView != nil ) {
		[meetMapView removeAnnotations:meetMapView.annotations];
		for ( MKMapView *sub in [self.mapView subviews] )	
			[sub removeFromSuperview];
		meetMapView = nil ;
	}
}

- (void)refreshMap {
	if ( [meetMapView.annotations count] )
		[meetMapView removeAnnotations:meetMapView.annotations];
//	if ( [dbmeets count] ) [meetMapView removeAnnotations:meetMapView.annotations];
	
	[self setMeetAnnotates] ;
//	[self zoomToFitMapAnnotations];
}

- (void)refreshMeetMap {
//	if ([dbmeets count] ){
//		[meetMapView removeAnnotations:meetMapView.annotations];
//		[dbmeets removeAllObjects];
//	}
	if ( [meetMapView.annotations count] )
		 [meetMapView removeAnnotations:meetMapView.annotations];
//	[KYMeet getMeetsFromDB:dbmeets]; 
	[self setMeetAnnotates] ;
	[self zoomToFitMapAnnotations];
//	[dbmeets removeAllObjects];
}

- (BOOL) matchMeet:(KYMeet*)mt
{
	if ( mt == nil ) return false ;
	if ( showType == MEET_ALL ) return true ;
	else if ( showType == MEET_SOLO && mt.userCount == 1 ) return true ;
	else if ( showType == MEET_PRIVATE && mt.userCount == 2 ) return true ;
	else if ( showType == MEET_GROUP && mt.userCount > 2 ) return true ;
	return false ;
}

- (void) setMeetAnnotates {
	int count = 0 ; // currently only show latest 20 meets

	
	kaya_meetAppDelegate *appDelegate = [kaya_meetAppDelegate getAppDelegate];
	placeDisplayMap *ann = [[placeDisplayMap alloc] init]; 
	CLLocationCoordinate2D cord ;
	cord.latitude  = appDelegate.latitude ;
	cord.longitude = appDelegate.longitude;
	ann.coordinate = cord ;
	ann.dataType = -2 ;
	ann.title = @"You are here now!" ;
	[meetMapView addAnnotation:ann] ;
	[ann release];	
	
	for( KYMeet *mt in dbmeets ) {
		if ( [self matchMeet:mt] == false )  continue ; 
		placeDisplayMap *ann = [[placeDisplayMap alloc] init]; 
		CLLocationCoordinate2D cord ;
		cord.latitude = mt.latitude ;
		cord.longitude = mt.longitude;
		ann.coordinate = cord ;
		if( mt.userCount > 1 ) {
			ann.title = [[NSString alloc] initWithString:mt.description] ;
			ann.dataid = mt.meetId ;
		} else {
			ann.dataType = -1 ;
		}
		ann.dataType = mt.userCount;
		[meetMapView addAnnotation:ann];
		[ann release];
		if ( count ++ > 30 ) return ;
	}

}

-(MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation {
	MKPinAnnotationView *pinView = nil; 

	if([annotation isKindOfClass:[placeDisplayMap class]]) 
	{
		NSString *defaultPinID = ((placeDisplayMap *)annotation).dataType==-2? @"com.kayameet.mapPin.userlocation":@"com.kayameet.mapPin";
		pinView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
		if ( pinView == nil ) {
				pinView = [[[MKPinAnnotationView alloc]
							initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease] ;
			if ( defaultPinID == @"com.kayameet.mapPin") {
					UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
					pinView.rightCalloutAccessoryView = rightButton ;
			}
			else {
				pinView.image = [UIImage imageNamed:@"ball.png"];
				[meetMapView bringSubviewToFront:pinView];
			}
		}
		if( ((placeDisplayMap *)annotation).dataType > 1 )
			pinView.pinColor = MKPinAnnotationColorGreen; 
		else						  
			pinView.pinColor = MKPinAnnotationColorRed;
				
		pinView.canShowCallout = YES;
		pinView.animatesDrop = NO;
		pinView.annotation = annotation ;

		//	[self performSelector:@selector(openCallout:) withObject:annotation afterDelay:0.5];
		return pinView;
	} 
	else return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if(! [view.annotation isKindOfClass:[placeDisplayMap class]]) return ;
	placeDisplayMap *ann = (placeDisplayMap *)view.annotation ;
	if ( ann.dataType < 0 ) return ;
	//KYMeet *mt = [dbmeets objectAtIndex:ann.dataid];
	KYMeet *mt = [[KYMeet meetWithId:ann.dataid] retain];
	MeetDetailView* meetDetailView = [[[MeetDetailView alloc] initWithMeet:mt] autorelease];
	meetDetailView.hidesBottomBarWhenPushed = YES;
	[[self navigationController] pushViewController:meetDetailView animated:TRUE];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
//	[meetMapView release] ;
//	self.meetMapView = nil ;
    [super viewDidUnload];
//	[dbmeets removeAllObjects];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

-(void)zoomToFitMapAnnotations
{
    //if([meetMapView.annotations count] == 0)
   //     return;
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	
	span.latitudeDelta=0.2;
	span.longitudeDelta=0.2;
	kaya_meetAppDelegate *appDelegate = [kaya_meetAppDelegate getAppDelegate];
	CLLocationCoordinate2D cord ;
	cord.latitude  = appDelegate.latitude +0.1;
	cord.longitude = appDelegate.longitude;
	
	CLLocationCoordinate2D location = cord;
		
	region.span = span;
	region.center = location;
	[meetMapView regionThatFits:region];
	[meetMapView setRegion:region animated:TRUE];
	return ;
    
	CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(placeDisplayMap *annotation in meetMapView.annotations)
    {
		if ((MKUserLocation*)annotation == meetMapView.userLocation) continue;
		
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [meetMapView regionThatFits:region];
    [meetMapView setRegion:region animated:YES];
}

-(void)observeValueForKeyPath:(NSString *)keyPath  
                     ofObject:(id)object  
                       change:(NSDictionary *)change  
                      context:(void *)context {  
	
    if ([self.meetMapView isUserLocationVisible]) {  
		[self.meetMapView setCenterCoordinate:self.meetMapView.userLocation.location.coordinate
									 animated:YES];
    }
}


// segmentedControl
- (void) typeSelected:(id)sender
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	
	showType=[segmentedControl selectedSegmentIndex];
	
	[self refreshMap];
}

@end
