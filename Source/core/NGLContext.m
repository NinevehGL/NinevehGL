/*
 *	NGLContext.m
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *  Created by Diney Bomfim on 10/14/11.
 *  Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLContext.h"

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
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

static EAGLSharegroup *_nglGroup = nil;

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

EAGLContext *nglContextEAGL(void)
{
	EAGLContext *contextEAGL = [EAGLContext currentContext];
	
	if (contextEAGL == nil)
	{
		EAGLRenderingAPI api;
		
		// Choose the correct API.
		switch (nglDefaultEngine)
		{
			case NGLEngineVersionES2:
			default:
				api = kEAGLRenderingAPIOpenGLES2;
				break;
		}
		
		// The first context created will generate the sharegroup (usually done in the main thread).
		// NinevehGL shares all resources between all contexts, useful when changing multithreading.
		contextEAGL = [[[EAGLContext alloc] initWithAPI:api sharegroup:_nglGroup] autorelease];
		_nglGroup = (_nglGroup) ? _nglGroup : contextEAGL.sharegroup;
		
		// Commit changes and set the new EAGLContext.
		[EAGLContext setCurrentContext:contextEAGL];
	}
	
	return contextEAGL;
}

void nglContextDeleteCurrent(void)
{
	// Commit changes and set the new EAGLContext.
	[EAGLContext setCurrentContext:nil];
}

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

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

