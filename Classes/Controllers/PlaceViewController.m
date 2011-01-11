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

@implementation PlaceViewController

@synthesize meets, meetMapView ;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	meets = [[NSMutableArray alloc] init];
	showType = MEET_ALL ;
}

- (void)viewWillAppear:(BOOL)animate {
	[self refreshMeetMap] ;
}

- (void)refreshMeetMap {
	if ([meets count] ){
		[meetMapView removeAnnotations:meetMapView.annotations];
		[meets removeAllObjects];
	}
	[KYMeet getMeetsFromDB:meets]; 
	[self setMeetAnnotates] ;
	[self zoomToFitMapAnnotations];
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
	for( KYMeet *mt in meets ) {
		if ( [self matchMeet:mt] == false ) { count ++ ; continue ; }
		placeDisplayMap *ann = [[placeDisplayMap alloc] init]; 
		CLLocationCoordinate2D cord ;
		cord.latitude = mt.latitude ;
		cord.longitude = mt.longitude;
		ann.coordinate = cord ;
		if( mt.userCount > 1 ) {
			ann.title = [[NSString stringWithFormat:@"%@",mt.description] retain] ;
			ann.dataid = count ;
		} else {
			ann.dataid = -1 ;
		}
		ann.dataType = mt.userCount;
		[meetMapView addAnnotation:ann];
		[ann release];
		if ( count ++ > 50 ) return ;
	}
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
	static MKPinAnnotationView *pinView = nil; 
	if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	if([annotation isKindOfClass:[placeDisplayMap class]]) 
	{
		static NSString *defaultPinID = @"com.kayameet.mapPin";
		pinView = (MKPinAnnotationView *)[meetMapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
		if ( pinView == nil ) {
				pinView = [[[MKPinAnnotationView alloc]
							initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
				UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
				pinView.rightCalloutAccessoryView = rightButton ;
				//pinView.image = [UIImage imageNamed:@"07-map-marker.png"];
		}
		if( ((placeDisplayMap *)annotation).dataType > 1 )
			pinView.pinColor = MKPinAnnotationColorGreen; 
		else						  
			pinView.pinColor = MKPinAnnotationColorRed;
		pinView.canShowCallout = YES;
		pinView.animatesDrop = NO;
		pinView.annotation = annotation ;

		//	[self performSelector:@selector(openCallout:) withObject:annotation afterDelay:0.5];
	} 
	return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if(! [view.annotation isKindOfClass:[placeDisplayMap class]]) return ;
	placeDisplayMap *ann = (placeDisplayMap *)view.annotation ;
	if ( ann.dataid < 0 ) return ;
	KYMeet *mt = [meets objectAtIndex:ann.dataid];
	MeetDetailView* meetDetailView = [[[MeetDetailView alloc] initWithMeet:mt] autorelease];
	meetDetailView.hidesBottomBarWhenPushed = YES;
	[[self navigationController] pushViewController:meetDetailView animated:TRUE];
    //do your show details thing here...
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[meets removeAllObjects];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[meetMapView release];
	[meets release];
}

-(void)zoomToFitMapAnnotations
{
    if([meetMapView.annotations count] == 0)
        return;
    
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
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [meetMapView regionThatFits:region];
    [meetMapView setRegion:region animated:YES];
}


// segmentedControl
- (void) typeSelected:(id)sender
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	
	showType=[segmentedControl selectedSegmentIndex];
	
	[self refreshMeetMap];
}

@end
