//
//  DisplayMapController.m
//  SimpleMemo
//
//  Created by Your Name on 11/02/06.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "DisplayMapController.h"


@implementation DisplayMapController


- (id)initWithLatitude:(double)latitude AndLongitude:(double)longitude
{
	if ( self = [super init] ) {
		latitude_ = latitude;
		longitude_ = longitude;
	}
	
	return self;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = latitude_;
	coordinate.longitude = longitude_;
	
	CLLocation *location = [[[CLLocation alloc]
							 initWithLatitude:latitude_ longitude:longitude_]
							autorelease];
	
	SimpleAnnotation *annotation = [[[SimpleAnnotation alloc] init] autorelease];
	annotation.location = location;
	
	MKCoordinateRegion cr = mapView_.region;
	cr.center = coordinate;
	cr.span.latitudeDelta = 0.01;
	cr.span.longitudeDelta = 0.01;
	[mapView_ setRegion:cr animated:NO];
	[mapView_ addAnnotation:annotation];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self dismissModalViewControllerAnimated:YES];
}


@end


#pragma mark -
#pragma mark SimpleAnnotation 


/*
 * 地図上のピン
 */

@implementation SimpleAnnotation

@synthesize location = location_;

- (void)dealloc
{
	[location_ release];
	[super dealloc];
}

- (CLLocationCoordinate2D)coordinate 
{
	return self.location.coordinate;
}

@end