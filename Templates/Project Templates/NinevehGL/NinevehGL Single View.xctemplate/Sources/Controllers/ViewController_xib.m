/*
 *	___VARIABLE_classPrefix:identifier___ViewController.m
 *	___PROJECTNAME___
 *	
 *	Created by ___FULLUSERNAME___ on ___DATE___.
 *	Copyright ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
 */

#import "___VARIABLE_classPrefix:identifier___ViewController.h"

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

@implementation ___VARIABLE_classPrefix:identifier___ViewController

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

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

- (void) drawView
{
	_mesh.rotateY += 2.0f;
	_mesh.rotateX -= 0.5f;
	
	[_camera drawCamera];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) viewDidLoad
{
	// Must call super to agree with the UIKit rules.
	[super viewDidLoad];
	
	// Setting the loading process parameters. To take advantage of the NGL Binary feature,
	// remove the line "kNGLMeshOriginalYes, kNGLMeshKeyOriginal,". Your mesh will be loaded 950% faster.
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  kNGLMeshOriginalYes, kNGLMeshKeyOriginal,
							  kNGLMeshCentralizeYes, kNGLMeshKeyCentralize,
							  @"0.3", kNGLMeshKeyNormalize,
							  nil];
	
	_mesh = [[NGLMesh alloc] initWithFile:@"cube.obj" settings:settings delegate:nil];
	
	_camera = [[NGLCamera alloc] initWithMeshes:_mesh, nil];
	[_camera autoAdjustAspectRatio:YES animated:YES];
	
	// Starts the debug monitor.
	[[NGLDebug debugMonitor] startWithView:(NGLView *)self.view];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void) dealloc
{
	[_mesh release];
	[_camera release];
	
	[super dealloc];
}

@end