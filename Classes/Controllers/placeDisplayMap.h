//
//  placeDisplayMap.h
//  kaya_meet
//
//  Created by Jun Li on 12/27/10.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface placeDisplayMap : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate; 
	NSString *title; 
	NSString *subtitle;
	uint64_t		  dataid  ;
	int		  dataType;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate; 
@property (nonatomic, assign) NSString *title; 
@property (nonatomic, assign) NSString *subtitle;
@property (nonatomic, assign) int  dataType;
@property (nonatomic, assign) uint64_t  dataid;
@end
