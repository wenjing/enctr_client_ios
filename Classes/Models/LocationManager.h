//
//  LocationManager.h
//  
//  Copyright 2010 Kaya Labs, Inc. All rights reserved.
//  
//  Versions :
//
//  Created by Jun Li on 10/11/2010.

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate> {
    CLLocationManager*  locationManager;
    CLLocation*         location;
    NSTimer*            timer;
    id                  delegate;
}

- (id)initWithDelegate:(id)delegate;
- (void)getCurrentLocation;
@end

