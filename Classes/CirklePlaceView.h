//
//  CirklePlaceView.h
//  Cirkle
//
//  Created by Wenjing Chu on 4/20/11.
//  Copyright 2011 Kaya Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CirklePlaceView : UIView <MKMapViewDelegate> {
    NSArray         *places;
    MKMapView       *mapView;
}
@property (nonatomic, retain) NSArray *places;
@property (nonatomic, retain) MKMapView *mapView;

- (id)initWithFrame:(CGRect)frame listOfPlaces:(NSArray *)list;
- (void)viewWillAppear:(BOOL)animate;
- (void)viewDidDisappear:(BOOL)animated;
@end
