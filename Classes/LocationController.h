//
//  LocationController.h
//  QuickTweet
//
//  Created by Your Name on 11/02/02.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationControllerDelegate
- (void)updateCoordinate:(CLLocationCoordinate2D)coordinate;
@end



@interface LocationController : NSObject<CLLocationManagerDelegate> {
	CLLocationManager *locationManager_;
	
	id<LocationControllerDelegate> delegate;
}

@property (nonatomic, assign) id<LocationControllerDelegate> delegate;

+ (id)sharedObject;
- (void)yobidashi;
- (void)stop;

@end
