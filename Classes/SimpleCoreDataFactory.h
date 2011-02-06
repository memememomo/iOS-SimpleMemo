//
//  SimpleCoreDataFactory.h
//  MyTestable
//
//  Created by Your Name on 11/01/19.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SimpleCoreData.h"

@interface SimpleCoreDataFactory : NSObject<NSFetchedResultsControllerDelegate> {
	NSInteger fetchBatchSize_;
	NSString *cacheName_;
	NSString *xcdatamodelName_; 
	NSString *sqliteName_;
	id fetchDelegate_;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	NSManagedObjectModel *managedObjectModel_;
	NSManagedObjectContext *managedObjectContext_;
}

@property (nonatomic, retain) NSString *cacheName;
@property (nonatomic, retain) NSString *xcdatamodelName;
@property (nonatomic, retain) NSString *sqliteName;
	
+ (id)sharedCoreData;

- (NSFetchRequest *)createRequest:(NSString *)entityName;
- (NSFetchRequest *)setSortDescriptors:(NSFetchRequest *)request AndSort:(NSDictionary *)sorts;
- (NSFetchRequest *)setPredicate:(NSFetchRequest *)request WithPredicate:(NSPredicate *)predicate;
- (NSFetchRequest *)setFunction:(NSFetchRequest *)request WithColumn:(NSString *)column AndFunction:(NSString *)funcName AndSetName:(NSString *)setName AndResultType:(NSInteger)resultType;
- (NSFetchedResultsController *)fetchedResultsController:(NSFetchRequest *)request AndSectionNameKeyPath:(NSString *)sectionNameKeyPath;
- (SimpleCoreData *)createSimpleCoreData:(NSFetchedResultsController *)controller;
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSURL *)applicationDocumentsDirectory;

@end
