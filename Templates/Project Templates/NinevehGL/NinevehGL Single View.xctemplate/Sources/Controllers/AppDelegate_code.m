/*
 *	___VARIABLE_classPrefix:identifier___AppDelegate.m
 *	___PROJECTNAME___
 *	
 *	Created by ___FULLUSERNAME___ on ___DATE___.
 *	Copyright ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
 */

#import "___VARIABLE_classPrefix:identifier___AppDelegate.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation ___VARIABLE_classPrefix:identifier___AppDelegate

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize window = _window, viewController = _viewController;

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options
{
	// Initializes the View Controller.
	_viewController = [[___VARIABLE_classPrefix:identifier___ViewController alloc] init];
	
	// Initializes the UIWindow.
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[_window setRootViewController:_viewController];
	[_window makeKeyAndVisible];
	
	return YES;
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state.
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, etc.
	// At this point, NinevehGL will automatically stops the renders.
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state.
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive.
	// At this point, NinevehGL will resume the renders.
}

- (void) applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate.
}

- (void) dealloc
{
	[_viewController release];
	[_window release];
	
	[super dealloc];
}

@end