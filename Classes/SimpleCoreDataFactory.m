//
//  SimpleCoreDataFactory.m
//  MyTestable
//
//  Created by Your Name on 11/01/19.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "SimpleCoreDataFactory.h"
#import "SimpleCoreData.h"

@implementation SimpleCoreDataFactory

SimpleCoreDataFactory *aSharedCoreData = nil;

@synthesize cacheName = cacheName_;
@synthesize xcdatamodelName = xcdatamodelName_;
@synthesize sqliteName = sqliteName_;

+ (id)sharedCoreData 
{
	@synchronized (self) {
		if (aSharedCoreData == nil) {
			aSharedCoreData = [self new];
		}
	}
	
	return aSharedCoreData;
}

- (void)dealloc {
	[cacheName_ release];
	[xcdatamodelName_ release];
	[sqliteName_ release];

	
	if (persistentStoreCoordinator_)
		[persistentStoreCoordinator_ release];
	
	if (managedObjectModel_) 
		[managedObjectModel_ release];
	
	if (managedObjectContext_)
		[managedObjectContext_ release];
	
	[super dealloc];
}


- (id)init 
{
	if ( self = [super init] ) {
		fetchBatchSize_ = 20;
		cacheName_ = @"Root";
		persistentStoreCoordinator_ = nil;
		managedObjectModel_ = nil;
		managedObjectContext_ = nil;
	}
	return self;
}

- (NSFetchRequest *)createRequest:(NSString *)entityName
{
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchBatchSize:fetchBatchSize_];

	return fetchRequest;
}

- (NSFetchRequest *)setSortDescriptors:(NSFetchRequest *)request AndSort:(NSDictionary *)sorts
{
	NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
	
	for (id key in sorts) {
		BOOL ascending = [[sorts valueForKey:key] boolValue];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
											initWithKey:key
											ascending:ascending];
		[sortDescriptors addObject:sortDescriptor];
		[sortDescriptor release];
	}
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	
	return request;
}

- (NSFetchRequest *)setPredicate:(NSFetchRequest *)request WithPredicate:(NSPredicate *)predicate
{
	[request setPredicate:predicate];
	[NSFetchedResultsController deleteCacheWithName:@"Root"];
	
	return request;
}

- (NSFetchRequest *)setFunction:(NSFetchRequest *)request 
		 WithColumn:(NSString *)column 
		AndFunction:(NSString *)funcName 
		 AndSetName:(NSString *)setName
	  AndResultType:(NSInteger)resultType
{
	NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:column];
	NSExpression *expression = [NSExpression expressionForFunction:[NSString stringWithFormat:@"%@:",funcName]
														 arguments:[NSArray arrayWithObject:keyPathExpression]];
	
	NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
	[expressionDescription setName:setName];
	[expressionDescription setExpression:expression];
	[expressionDescription setExpressionResultType:resultType];
	
	[request setResultType:NSDictionaryResultType];
	[request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
	
	[expressionDescription release];
	
	return request;
}

- (NSFetchedResultsController *)fetchedResultsController:(NSFetchRequest *)request 
								   AndSectionNameKeyPath:(NSString *)sectionNameKeyPath
{
	NSFetchedResultsController *fetchedResultsController = [[[NSFetchedResultsController alloc]
															 initWithFetchRequest:request
															 managedObjectContext:[self managedObjectContext]
															 sectionNameKeyPath:sectionNameKeyPath
															 cacheName:nil]
															autorelease];
															
	
	NSError *error = nil;
	if ( ![fetchedResultsController performFetch:&error] ) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	return fetchedResultsController;
}

- (SimpleCoreData *)createSimpleCoreData:(NSFetchedResultsController *)controller
{
	SimpleCoreData *simpleCoreData = [[[SimpleCoreData alloc]
									  initWithController:controller]
									  autorelease];
	simpleCoreData.fetchedResultsController.delegate = simpleCoreData;
	
	return simpleCoreData;
}

- (NSManagedObjectContext *)managedObjectContext 
{
	if (managedObjectContext_ != nil) {
		return managedObjectContext_;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	
	if (coordinator != nil) {
		managedObjectContext_ = 
		[[NSManagedObjectContext alloc] init];
		[managedObjectContext_ setPersistentStoreCoordinator:coordinator];
	}
	
	return managedObjectContext_;
}


- (NSManagedObjectModel *)managedObjectModel 
{
	if (managedObjectModel_ != nil) {
		return managedObjectModel_;
	}

	
	NSString *modelPath = [[NSBundle mainBundle] 
						   pathForResource:self.xcdatamodelName
						   ofType:@"mom"];
	
	NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
	managedObjectModel_ = [[NSManagedObjectModel alloc]
						   initWithContentsOfURL:modelURL];
	
	return managedObjectModel_;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
	if (persistentStoreCoordinator_ != nil) {
		return persistentStoreCoordinator_;
	}
	
	NSURL *storeURL = 
	[[self applicationDocumentsDirectory]
	 URLByAppendingPathComponent:self.sqliteName];
	NSError *error = nil;
	
	persistentStoreCoordinator_ = 
	[[NSPersistentStoreCoordinator alloc]
	 initWithManagedObjectModel:[self managedObjectModel]];
	
	if ( ![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType 
													configuration:nil 
															  URL:storeURL 
														  options:nil error:&error] ) 
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	
	return persistentStoreCoordinator_;
}

- (NSURL *)applicationDocumentsDirectory 
{
	return [[[NSFileManager defaultManager]
			 URLsForDirectory:NSDocumentDirectory
			 inDomains:NSUserDomainMask] lastObject];
}

@end
