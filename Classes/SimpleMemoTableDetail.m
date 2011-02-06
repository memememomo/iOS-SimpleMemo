//
//  SimpleMemoTableDetail.m
//  SimpleMemo
//
//  Created by Your Name on 11/02/05.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "SimpleMemoTableDetail.h"
#import "DisplayImageController.h"
#import "DisplayMapController.h"


@implementation SimpleMemoTableDetail


@synthesize indexPath = indexPath_;
@synthesize simpleCoreData = simpleCoreData_;


- (void)dealloc
{
	[indexPath_ release];
	[super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSManagedObject *managedObject = [self.simpleCoreData.fetchedResultsController objectAtIndexPath:self.indexPath];
	textView_.text = [managedObject valueForKey:@"text"];
	
	double latitude = [[managedObject valueForKey:@"latitude"] doubleValue];
	double longitute = [[managedObject valueForKey:@"longitude"] doubleValue];
	
	if (!latitude || !longitute) {
		map_.enabled = NO;
	}
	
	NSString *imagePath = [managedObject valueForKey:@"imagePath"];
	if (!imagePath || [imagePath isEqualToString:@""]) {
		camera_.enabled = NO;
	}
	
	toolBar_.hidden = NO;
}


- (void)displayMap
{
	NSManagedObject *managedObject = [self.simpleCoreData.fetchedResultsController objectAtIndexPath:self.indexPath];
	
	double latitude = [[managedObject valueForKey:@"latitude"] doubleValue];
	double longitute = [[managedObject valueForKey:@"longitude"] doubleValue];
	

	DisplayMapController *mapController = [[[DisplayMapController alloc]
											initWithLatitude:latitude AndLongitude:longitute]
										   autorelease];
	
	[self presentModalViewController:mapController animated:YES];
}


- (void)displayImage
{
	NSManagedObject *managedObject = [self.simpleCoreData.fetchedResultsController objectAtIndexPath:self.indexPath];


	NSString *imagePath = [managedObject valueForKey:@"imagePath"];
	
	DisplayImageController *displayImage = [[[DisplayImageController alloc]
											 initWithImagePath:imagePath]
											autorelease];
	
	[self presentModalViewController:displayImage animated:YES];
}


@end
