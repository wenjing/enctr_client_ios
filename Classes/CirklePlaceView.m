//
//  CirklePlaceView.m
//  Cirkle
//
//  Created by Wenjing Chu on 4/20/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import "CirklePlaceView.h"
#import "kaya_meetAppDelegate.h"
#import "placeDisplayMap.h"
#import "CirkleDetail.h"
#import "CirkleDetailView.h"

@implementation CirklePlaceView
@synthesize places;
@synthesize mapView;

- (id)initWithFrame:(CGRect)frame listOfPlaces:(NSArray *)list
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor blueColor]];
        places = list;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [mapView release];
    [places release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animate {
    NSLog(@"map's holding view will appear");
    
    if (mapView == nil) {
        mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width, self.frame.size.height)];
        mapView.delegate = self;
        [self addSubview:mapView];
    }
    
    kaya_meetAppDelegate *appDelegate = [kaya_meetAppDelegate getAppDelegate];
    
    [appDelegate addObserver:self 
                  forKeyPath:@"latitude" 
                     options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
                     context:NULL];
    
    mapView.showsUserLocation=TRUE;
    
    CLLocationCoordinate2D cord;
    
    /*
    // first my location
    placeDisplayMap *ann = [[placeDisplayMap alloc] init]; 
	cord.latitude  = appDelegate.latitude;
	cord.longitude = appDelegate.longitude;
	ann.coordinate = cord ;
	
	ann.title = @"You are here";
	[mapView addAnnotation:ann];
    //dataid ?
    
	[ann release];	
    */
    // add location events
    CirkleDetail *event;
    
    for (NSUInteger i = 0; i < [places count]; i++) {
        
        event = [places objectAtIndex:i];
        
        //add annotation if there is geo info
        if (event.latitude == 0 ||
            event.longitude == 0) {
            continue;
        }
        
        placeDisplayMap *ann = [[placeDisplayMap alloc] init]; 
		CLLocationCoordinate2D cord ;
		cord.latitude = event.latitude ;
		cord.longitude = event.longitude;
		ann.coordinate = cord;
		
        ann.title = [[NSString alloc] initWithString:event.nameString];
        //ann.subtitle = [[NSString alloc] initWithString:event.contentString];
        
        ann.dataid = i;
		
		[mapView addAnnotation:ann];
		[ann release];
    }
    
    // set region & center
    MKCoordinateRegion region;
	MKCoordinateSpan span;
	
	span.latitudeDelta = 0.2;
	span.longitudeDelta = 0.2;
	
	cord.latitude  = appDelegate.latitude;
	cord.longitude = appDelegate.longitude;
	
	CLLocationCoordinate2D location = cord;
    
	region.span = span;
	region.center = location;
	[mapView regionThatFits:region];
	[mapView setRegion:region animated:FALSE];

}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"map's holding view did disappear");
    //remove everything
    if ( mapView != nil ) {
		[mapView removeAnnotations:mapView.annotations];
		for ( MKMapView *sub in [self subviews] )	
			[sub removeFromSuperview];
		mapView = nil;
	}
}


#pragma -
#pragma MKMapView Delegate Methods
//The annotation view to display for the specified annotation or nil if you want to display a standard annotation view.
-(MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation {
    //NSLog(@"view for annotation");
    MKPinAnnotationView *pinView = nil;
    
    if([annotation isKindOfClass:[placeDisplayMap class]]) 
	{
        
		pinView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:@"CirkleMapAnnotIdentifier"];
		if ( pinView == nil ) {
            pinView = [[[MKPinAnnotationView alloc]
                        initWithAnnotation:annotation reuseIdentifier:@"CirkleMapAnnotIdentifier"] autorelease] ;
            
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton ;
		}
        
        pinView.pinColor = MKPinAnnotationColorGreen;
		pinView.canShowCallout = YES;
		pinView.animatesDrop = NO;
		pinView.annotation = annotation ;
        
		//	[self performSelector:@selector(openCallout:) withObject:annotation afterDelay:0.5];
		return pinView;
	} 

    return nil;
}

//Tells the delegate that the user tapped one of the annotation view’s accessory buttons.
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"callout accessory tapped");
    if([view.annotation isKindOfClass:[placeDisplayMap class]]) {
        placeDisplayMap *ann = (placeDisplayMap *)view.annotation;
        CirkleDetail *circle = [places objectAtIndex:ann.dataid];
        
        if (circle!=nil) {
            //display
            CGRect rect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            
            CirkleDetailView *circleDetailView = [[CirkleDetailView alloc] initWithFrame:rect];
            circleDetailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            [self.superview addSubview:circleDetailView];
            //[view addSubview:circleDetailView];
            
            circleDetailView.circleDetail = circle;
            
            circleDetailView.alpha = 0.0;
             
            [UIView animateWithDuration:5.0
                                  delay:0.0
                                options:UIViewAnimationOptionAutoreverse
                              animations:^{circleDetailView.alpha = 1;}
                             completion:^(BOOL finished){ [circleDetailView removeFromSuperview]; }];

            [circleDetailView release];
        }
        
    }
}

#pragma -
#pragma Key Observing Callback

-(void)observeValueForKeyPath:(NSString *)keyPath  
                     ofObject:(id)object  
                       change:(NSDictionary *)change  
                      context:(void *)context {  
    NSLog(@"observe value key callback");
    
	//center with current location
    if ([mapView isUserLocationVisible]) {  
		[mapView setCenterCoordinate:mapView.userLocation.location.coordinate
									 animated:YES];
    }
}



@end
