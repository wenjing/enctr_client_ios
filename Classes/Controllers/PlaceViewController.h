//
//  PlaceViewController.h
//  kaya_meet
//
//  Created by Jun Li on 1/1/11.
//  Copyright 2011 Anova Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "KYMeet.h"

@interface PlaceViewController : UIViewController<MKMapViewDelegate> {
	IBOutlet  MKMapView		*meetMapView ;
	NSMutableArray*			 meets;
}
@property(nonatomic, readonly)  NSMutableArray* meets;
@property(nonatomic, assign)    MKMapView* meetMapView;

-(void) zoomToFitMapAnnotations ;
-(void) refreshMeetMap;
-(void) setMeetAnnotates;

@end
