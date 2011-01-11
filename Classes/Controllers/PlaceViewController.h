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
	IBOutlet  MKMapView		*meetMapView ;
	NSMutableArray*			 meets;
	KAYA_MEET_SHOW_TYPE	showType  ;
	IBOutlet  UISegmentedControl *typeSelector;
}
@property(nonatomic, readonly)  NSMutableArray* meets;
@property(nonatomic, assign)    MKMapView* meetMapView;

-(void) zoomToFitMapAnnotations ;
-(void) refreshMeetMap;
-(void) setMeetAnnotates;

-(void) typeSelected:(id)sender;
@end
