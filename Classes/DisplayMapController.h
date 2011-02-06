//
//  DisplayMapController.h
//  SimpleMemo
//
//  Created by Your Name on 11/02/06.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface DisplayMapController : UIViewController {
	IBOutlet MKMapView *mapView_;
	double latitude_, longitude_;
}
- (id)initWithLatitude:(double)latitude AndLongitude:(double)longitude;

@end


@interface SimpleAnnotation : NSObject <MKAnnotation> {
	CLLocation *location_;
}

@property (nonatomic, copy) CLLocation *location;
@end