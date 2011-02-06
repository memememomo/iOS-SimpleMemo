//
//  SimpleCoreData.h
//  CoreDataTest
//
//  Created by memememomo on 10/12/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SimpleCoreData : NSObject<NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController_;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (id)initWithController:(NSFetchedResultsController *)controller;
- (NSArray *)fetchObjectAll;
- (NSManagedObject *)fetchObjectWithRow:(NSInteger)row AndSection:(NSInteger)section;
- (void)performFetch;
- (NSInteger)countObjects;
- (NSInteger)countSections;
- (void)deleteObjectWithRow:(NSInteger)row AndSection:(NSInteger)section;
- (void)deleteObjectWithObject:(NSManagedObject *)managedObject;
- (void)deleteObjectWithIndexPath:(NSIndexPath *)indexPath;
- (NSManagedObject *)newManagedObject;
- (void)saveContext;

@end
