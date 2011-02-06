
//
//  SimpleCoreData.m
//  CoreDataTest
//
//  Created by memememomo on 10/12/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SimpleCoreData.h"
#import "SimpleCoreDataFactory.h"

@implementation SimpleCoreData

@synthesize fetchedResultsController = fetchedResultsController_;

- (void)dealloc {
	[fetchedResultsController_ release];
	[super dealloc];
}

- (id)initWithController:(NSFetchedResultsController *)controller
{
	if ( self = [super init] ) {
		fetchedResultsController_ = controller;
		[fetchedResultsController_ retain];
	}
	return self;
}


- (NSArray *)fetchObjectAll
{
	NSManagedObjectContext *moc = [[SimpleCoreDataFactory sharedCoreData] managedObjectContext];
	NSFetchRequest *request = self.fetchedResultsController.fetchRequest;
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	return array;
}

- (NSManagedObject *)fetchObjectWithRow:(NSInteger)row AndSection:(NSInteger)section  
{
	NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
	return [self.fetchedResultsController objectAtIndexPath:path];
}

- (NSInteger)countObjects
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
	return [sectionInfo numberOfObjects];
}

- (NSInteger)countSections
{
	return [[self.fetchedResultsController sections] count];	
}

- (void)deleteObjectWithRow:(NSInteger)row AndSection:(NSInteger)section 
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
	[self deleteObjectWithIndexPath:indexPath];
}

- (void)deleteObjectWithIndexPath:(NSIndexPath *)indexPath 
{
	@try {
		NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
		if (managedObject) {
			[self deleteObjectWithObject:managedObject];
		}
	}
	@catch (NSException * e) {
		NSLog(@"%@", e);
	}
}

- (void)deleteObjectWithObject:(NSManagedObject *)managedObject 
{
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	[context deleteObject:managedObject];
	[self saveContext];
}

- (NSManagedObject *)newManagedObject
{
	NSManagedObjectContext *managedObjectContext = [self.fetchedResultsController managedObjectContext];
	NSFetchRequest *request = self.fetchedResultsController.fetchRequest;
	NSString *entityName = [[request entity] name];
	NSManagedObject *newManagedObject = [NSEntityDescription
										 insertNewObjectForEntityForName:entityName
										 inManagedObjectContext:managedObjectContext];
	return newManagedObject;
}

- (void)saveContext 
{
	NSManagedObjectContext *managedObjectContext = [self.fetchedResultsController managedObjectContext];
	
	if (managedObjectContext != nil) {
		NSError *error = nil;
		if ([managedObjectContext hasChanges] && 
			![managedObjectContext save:&error]) 
		{
			abort();
		}
	}
}

- (void)performFetch
{
	NSError *error = nil;
	if ( ![self.fetchedResultsController performFetch:&error] ) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	
}

@end
