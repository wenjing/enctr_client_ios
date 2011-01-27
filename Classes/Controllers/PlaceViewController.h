//
//  PlaceViewController.h
//  kaya_meet
//
//  Created by Jun Li on 1/1/11.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "KYMeet.h"

@interface PlaceViewController : UIViewController<MKMapViewDelegate> {
	IBOutlet UIView		*mapView;
	MKMapView	*meetMapView ;
	NSArray*			 dbmeets;
	KAYA_MEET_SHOW_TYPE	showType  ;
	IBOutlet  UISegmentedControl *typeSelector;
}
@property(nonatomic, readonly)  NSArray* dbmeets;
@property(nonatomic, assign)    MKMapView* meetMapView;
@property(nonatomic, assign)    UIView* mapView;

-(void) zoomToFitMapAnnotations ;
-(void) refreshMeetMap;
-(void) setMeetAnnotates;

-(void) refreshMap;
-(void) typeSelected:(id)sender;
@end
