//
//  SimpleMemoAppDelegate.m
//  SimpleMemo
//
//  Created by Your Name on 11/02/05.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "SimpleMemoAppDelegate.h"
#import "SimpleCoreDataFactory.h"
#import "SimpleMemoInput.h"
#import "SimpleMemoTable.h"

@implementation SimpleMemoAppDelegate


#pragma mark -
#pragma mark Helper

- (UINavigationController *)createNavControllerWrappingViewControllerOfClass:(Class)cntrloller 
																	 nibName:(NSString*)nibName 
																 tabIconName:(NSString*)iconName
																	tabTitle:(NSString*)tabTitle
{
	UIViewController* viewController = [[cntrloller alloc] initWithNibName:nibName bundle:nil];
	
	UINavigationController *theNavigationController;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	viewController.tabBarItem.image = [UIImage imageNamed:iconName];
	viewController.title = NSLocalizedString(tabTitle, @""); 
	[viewController release];
	
	return theNavigationController;
}


- (void)navigationController:(UINavigationController *)navigationController 
	  willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[viewController viewWillAppear:animated];
}


- (void)navigationController:(UINavigationController *)navigationController
	   didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[viewController viewDidAppear:animated];
}



#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// CoreDataの初期化
	SimpleCoreDataFactory *factory = [SimpleCoreDataFactory sharedCoreData];
	factory.xcdatamodelName = @"SimpleMemo";
	factory.sqliteName = @"SimpleMemo";
	
	
	CGRect frame = [[UIScreen mainScreen] bounds];
	window_ = [[UIWindow alloc] initWithFrame:frame];
	
	UINavigationController *localNavigationController;
	NSMutableArray *controllers = [[NSMutableArray alloc] init];
	
	tabBarController_ = [[UITabBarController alloc] init];
	
	
	// 入力画面
	localNavigationController = 
		[self createNavControllerWrappingViewControllerOfClass:[SimpleMemoInput class] 
																nibName:@"SimpleMemoInput"
															tabIconName:@""
															   tabTitle:@"MEMO_TITLE"];
	[controllers addObject:localNavigationController];
	[localNavigationController release];
	
	
	// リスト表示画面
	localNavigationController =
		[self createNavControllerWrappingViewControllerOfClass:[SimpleMemoTable class]
													   nibName:nil
												   tabIconName:nil
													  tabTitle:@"LIST_TITLE"];
	localNavigationController.delegate = self;
	[controllers addObject:localNavigationController];
	[localNavigationController release];
	
	
	tabBarController_.viewControllers = controllers;
	[controllers release];
	
	
	[window_ addSubview:tabBarController_.view];
    [window_ makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[tabBarController_ release];
    [window_ release];
    [super dealloc];
}


@end
