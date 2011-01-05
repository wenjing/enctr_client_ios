//
//  meetPlace.h
//  kaya_meet
//
//  Created by Jun Li on 1/1/11.
//  Copyright 2011 Anova Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface meetPlace : UITableViewController {
	IBOutlet   MKMapView	*placeView ;
	NSMutableArray*			 meets;
}

@end
