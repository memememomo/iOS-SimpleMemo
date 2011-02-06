//
//  LocationController.m
//  QuickTweet
//
//  Created by Your Name on 11/02/02.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "LocationController.h"


@implementation LocationController

static id sharedObject;

@synthesize delegate;


- (void)dealloc
{
	[sharedObject release];
	[locationManager_ release];
	[super dealloc];
}

+ (id)sharedObject
{
	if (!sharedObject) {
		sharedObject = [[LocationController alloc] init];
	}
	
	return sharedObject;
}

- (void)yobidashi 
{
	if ( nil == locationManager_ ) {
		locationManager_ = [[CLLocationManager alloc] init];
	}
	locationManager_.delegate = self;
	locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
	locationManager_.distanceFilter = kCLDistanceFilterNone;
	
	[locationManager_ startUpdatingLocation];
}

- (void)stop
{
	[locationManager_ stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager*)manager
	didUpdateToLocation:(CLLocation*)newLocation
		   fromLocation:(CLLocation*)oldLocation
{
	[delegate updateCoordinate:manager.location.coordinate];
}


- (void)locationManager:(CLLocationManager*)manager
	   didFailWithError:(NSError*)error
{
	UIAlertView *alertView = [[UIAlertView alloc]
							  initWithTitle:nil
							  message:NSLocalizedString(@"CANT_LOCATION", @"")
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}


@end
