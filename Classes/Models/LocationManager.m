//
//  LocationManager.m
//  
//  Copyright 2010 Kaya Labs, Inc. All rights reserved
//
// Version
// Created by Jun Li 10/12/2010

#import "LocationManager.h"
#import "kaya_meetAppDelegate.h"

@interface NSObject (LocationManagerDelegate)
- (void)locationManagerDidUpdateLocation :(LocationManager*)manager location:(CLLocation*)location;
- (void)locationManagerDidReceiveLocation:(LocationManager*)manager location:(CLLocation*)location;
- (void)locationManagerDidFail:(LocationManager*)manager;
@end

#define LM_TIMEOUT_TIME        40.0
#define LM_ACCURACY_THRESHOLD  100.0

@implementation LocationManager

- (id)initWithDelegate:(id)aDelegate
{
    [super init];
    delegate = aDelegate;
    location = nil;

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
//  Standard Location Service
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = LM_ACCURACY_THRESHOLD;	

    return self;
}

- (void)dealloc
{
    if (timer)    [timer invalidate];
    if (location) [location release];
    [locationManager release];
    [super dealloc];
}

- (void)getCurrentLocation
{
    [locationManager startUpdatingLocation];

//  Significant Location service
//  [locationManager startMonitoringSignificantLocationChanges];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    timer = [NSTimer scheduledTimerWithTimeInterval:LM_TIMEOUT_TIME
                                             target:self
                                           selector:@selector(locationManagerDidTimeout:userInfo:)
                                           userInfo:nil
                                            repeats:false];
}

- (void)locationManager:(CLLocationManager *)manager
        didUpdateToLocation:(CLLocation *)newLocation
               fromLocation:(CLLocation *)oldLocation
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];

    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    NSLog(@"%@ (%lf)", [newLocation description], howRecent);

    if ([delegate respondsToSelector:@selector(locationManagerDidUpdateLocation:location:)]) {
        [delegate locationManagerDidUpdateLocation:self location:newLocation];
    }

    if (location) [location release];
    location = [newLocation retain];

    if (abs(howRecent) < 10.0 && [newLocation horizontalAccuracy] < LM_ACCURACY_THRESHOLD) {
        [timer invalidate];
        timer = nil;
        [manager stopUpdatingLocation];

        [delegate locationManagerDidReceiveLocation:self location:newLocation];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}


- (void)locationManagerDidTimeout:(NSTimer*)aTimer userInfo:(id)userInfo
{
    timer = nil;
    [locationManager stopUpdatingLocation];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if (location) {
        NSDate* eventDate = location.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

        if ([location horizontalAccuracy] < 10000 && abs(howRecent) < LM_TIMEOUT_TIME + 5.0) {
            [delegate locationManagerDidReceiveLocation:self location:location];
            [location release];
            location = nil;
            return;
        }
        [location release];
        location = nil;
    }
//  warning to app
    [[kaya_meetAppDelegate getAppDelegate] alert:@"Location Service Error" message:@"Operation timeout"];

    [delegate locationManagerDidFail:self];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [locationManager stopUpdatingLocation];

    if (!([error code] == kCLErrorDenied && [[error domain] isEqualToString:kCLErrorDomain])) {
//  warning to app
		[[kaya_meetAppDelegate getAppDelegate] alert:@"Location Service Error" message:[error localizedDescription]];
    }
    else if ([error code] == kCLErrorLocationUnknown) {
        // Ignore this error and keep tracking
        return;
    }

    [timer invalidate];
    timer = nil;
    [location release];
    location = nil;
    [delegate locationManagerDidFail:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
