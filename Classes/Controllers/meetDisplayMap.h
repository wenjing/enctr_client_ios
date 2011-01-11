//
//  meetDisplayMap.h
//  kaya_meet
//
//  Created by Jun Li on 12/27/10.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface meetDisplayMap : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate; 
	NSString *title; 
	NSString *subtitle;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate; 
@property (nonatomic, assign) NSString *title; 
@property (nonatomic, assign) NSString *subtitle;

@end
